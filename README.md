# NAME

Cocoa::NetworkChange - Checking network connection for OS X

# SYNOPSIS

    use Cocoa::EventLoop;
    use Cocoa::NetworkChange;

    on_network_change(sub {
        my $wlan = shift;
        # on connected
        if ($wlan->{ssid} && $wlan->{ssid} =~ /aterm/) {
            # ...
        }
    }, sub {
        # on disconnected
    });

    Cocoa::EventLoop->run;

# DESCRIPTION

Cocoa::NetworkChange checks network connection in real time. You can do something when you connected to a certain Wi-Fi network.

Note that if you disconnected with PPPoE authentication, Cocoa::NetworkChange guesses that it's connected to the network.

# FUNCTIONS

## on\_network\_change($connect\_cb, $disconnect\_cb)

Call the callback on network connected or disconnected.

    on_network_change(sub {
        my $wlan = shift;
        # on connected
    }, sub {
        # on disconnected
    });

- $wlan->{ssid}

    SSID

- $wlan->{interface}

    Interface name (such as en0, en1)

- $wlan->{mac\_address}

    MAC address

## is\_network\_connected()

(immediately) Return 1, when you are connected to the network and 0 otherwise.

# LICENSE

Copyright (C) Takumi Akiyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Takumi Akiyama <t.akiym@gmail.com>
