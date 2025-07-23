
# Config.pm - Configuration module for the Network Health Monitor

package Config;

use strict;
use warnings;


sub get_config {
    my %config = (
        # 💻 List of servers to monitor
        servers => [
            {
                host  => 'localhost', 
                ports => [80, 22, 443] # Common ports: HTTP, SSH, HTTPS
            },
            {
                host  => 'google.com',
                ports => [80, 443]
            },
            {
                host => '192.168.1.250', # A non-existent local IP for testing failure
                ports => [8080]
            }
        ],

        # 📝 Log analysis settings
        log_analysis => {
            log_file => 'system.log',
            patterns => [
                'error',
                'failed',
                'login failure',
                'critical',
                'denied'
            ]
        },

        # 📧 Email alert settings
        email => {
            to          => 'admin@example.com', # <-- 
            from        => 'monitor@yourdomain.com', # <-- 
            smtp_server => 'smtp.example.com', # <-- 
    );
    return %config;
}

1; 
