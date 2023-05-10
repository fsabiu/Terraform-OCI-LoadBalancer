tenancy_ocid       = ""
user_ocid          = ""
fingerprint        = ""
private_key_path   = "../id_rsa_customer_iac_prv.pem"
region             = "eu-milan-1"
compartment_id     = ""

load_balancer_id = "ocid1.loadbalancer.oc1.eu-milan-1.aaaaaaaaXXXXXXxxxxxxXXXXXXXXXXu7jhej23qa"

# List of backend sets to be attached to the load balancer
backend_sets = [
    {
        name = "customer-sit-cabdev-app-ap"
        policy = "ROUND_ROBIN"
        health_checker = {
            protocol = "HTTP"
            interval_ms = 4000
            port = 8001
            retries = 5
            return_code = 200
            timeout_in_millis = 3000
            url_path = "/FCUBSAPP-ELCMWeb"
        }
    },
    {
        name = "customer-sit-cabdev-app-gw"
        policy = "ROUND_ROBIN"
        health_checker = {
            protocol = "HTTP"
            interval_ms = 4000
            port = 8001
            retries = 5
            return_code = 200
            timeout_in_millis = 3000
            url_path = "/"
        }
    }
]

# List of lists of backends to be added to each backend sets
# The list at position "i" will contain the backends of backend_sets[i] 
backends = [
        [
            {
                ip_address = "172.24.207.107"
                backup = false
                drain = false
                offline = false
                port = 8001
                weight = 1
            }
        ],
        [
            {
                ip_address = "172.24.207.107"
                backup = false
                drain = false
                offline = false
                port = 9001
                weight = 1
            }
        ]
]

# List of routing policies to be attached to the load balancer
routing_policies = [
    {
        condition_language_version = "V1"
        name = "customer_sit_rp_001_lb_cabdev_ap"
        rules = [
            {
            actions = [
                {
                backend_set_name = "customer-sit-cabdev-app-ap"
                name = "FORWARD_TO_BACKENDSET"
                }
            ]

            condition = "http.request.headers[(i 'Host')] eq (i 'cabdev.customertest.net')"
            name = "customer_sit_rp_001_lb_cabdev_ap"
            }
        ]
    },
    {
        condition_language_version = "V1"
        name = "customer_sit_rp_002_lb"
        rules = [
            {
            actions = [
                {
                backend_set_name = "customer-sit-cabdev-app-gw"
                name = "FORWARD_TO_BACKENDSET"
                }
            ]

            condition = "all(http.request.headers[(i 'Host')] eq (i 'cabdev.customer.net'), http.request.url.path eq (i '/console'))"
            name = "customer_sit_rp_001_lb_cabdev_gw"
            }
        ]
    }
]