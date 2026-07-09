class ReportGenerator:

    def generate(self, results: dict):

        planner = results["planner"]
        architecture = results["architecture"]
        security = results["security"]

        report = f"""

=========================================================
                CLOUDPILOT AI REPORT
=========================================================

PLANNER

Workload:
{planner["workload"]}

Business Goal:
{planner["business_goal"]}

Priority:
{planner["priority"]}

---------------------------------------------------------

ARCHITECTURE

Landing Zone:
{architecture["landing_zone"]}

Network:
{architecture["network_topology"]}

Compute:
{architecture["compute"]}

Storage:
{architecture["storage"]}

Backup:
{architecture["backup"]}

Disaster Recovery:
{architecture["disaster_recovery"]}

---------------------------------------------------------

SECURITY

Identity:
{security["identity"]}

Network:
{security["network_security"]}

Compliance:
{security["compliance"]}

Recommendations:
{security["recommendations"]}

=========================================================

"""

        return report