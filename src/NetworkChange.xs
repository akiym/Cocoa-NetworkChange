#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#define NEED_newSVpvn_flags
#include "ppport.h"

#include <notify.h>
#include <notify_keys.h>

#undef Move

#import <Foundation/Foundation.h>
#import <CoreWLAN/CoreWLAN.h>
#import <objc/runtime.h>

#import "Reachability.h"

MODULE = Cocoa::NetworkChange    PACKAGE = Cocoa::NetworkChange

PROTOTYPES: DISABLE

void
on_network_change(SV* sv_connect_cb, SV* sv_disconnect_cb)
CODE:
{
    SV* connect_cb = get_sv("Cocoa::NetworkChange::__connect_cb", GV_ADD);
    sv_setsv(connect_cb, sv_connect_cb);
    SV* disconnect_cb = get_sv("Cocoa::NetworkChange::__disconnect_cb", GV_ADD);
    sv_setsv(disconnect_cb, sv_disconnect_cb);

    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    Reachability* reach = [Reachability reachabilityForInternetConnection];
    reach.reachableBlock = ^(Reachability* reach){
        dispatch_sync(dispatch_get_main_queue(), ^{
            CWInterface* currentInterface = [CWInterface interfaceWithName:nil];

            SV* sv_ssid = sv_2mortal(newSV(0));
            SV* sv_interface_name = sv_2mortal(newSV(0));
            SV* sv_hardware_address = sv_2mortal(newSV(0));
            sv_setpv(sv_ssid, [[currentInterface ssid] UTF8String]);
            sv_setpv(sv_interface_name, [[currentInterface interfaceName] UTF8String]);
            sv_setpv(sv_hardware_address, [[currentInterface hardwareAddress] UTF8String]);

            HV* sv_interface = (HV*)sv_2mortal((SV*)newHV());
            (void)hv_store(sv_interface, "ssid", 4, sv_ssid, 0);
            (void)hv_store(sv_interface, "interface", 9, sv_interface_name, 0);
            (void)hv_store(sv_interface, "mac_address", 11, sv_hardware_address, 0);

            SV* connect_cb = get_sv("Cocoa::NetworkChange::__connect_cb", 0);
            if (connect_cb) {
                dSP;
                ENTER;
                SAVETMPS;

                PUSHMARK(SP);
                XPUSHs(sv_2mortal(newRV_inc((SV*)sv_interface)));
                PUTBACK;

                call_sv(connect_cb, G_SCALAR);

                SPAGAIN;

                PUTBACK;
                FREETMPS;
                LEAVE;
            }
        });
    };
    reach.unreachableBlock = ^(Reachability* reach){
        dispatch_sync(dispatch_get_main_queue(), ^{
            SV* disconnect_cb = get_sv("Cocoa::NetworkChange::__disconnect_cb", 0);
            if (disconnect_cb) {
                call_sv(disconnect_cb, G_SCALAR);
            }
        });
    };

    [reach startNotifier];

    [pool drain];
}
