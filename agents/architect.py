from typing import Dict

def design_architecture(requirement: str) -> Dict:

    requirement = requirement.lower()

    architecture = {}

    if "migrate" in requirement:

        architecture = {

            "landing_zone": "Enterprise Scale Landing Zone",

            "network": "Hub and Spoke",

            "compute": "Azure Virtual Machines",

            "storage": "Premium SSD",

            "backup": "Azure Backup",

            "dr": "Azure Site Recovery"

        }

    elif "web application" in requirement:

        architecture = {

            "compute": "Azure App Service",

            "database": "Azure SQL Database",

            "network": "Application Gateway",

            "security": "Web Application Firewall"

        }

    else:

        architecture = {

            "recommendation": "Need more information"

        }

    return architecture