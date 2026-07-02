from typing import Dict

def analyze_request(user_input: str) -> Dict:

    user_input = user_input.lower()

    agents = []

    workload = "General"

    if "migrate" in user_input:
        workload = "Migration"

    if "terraform" in user_input:
        workload = "Terraform"

    if "cost" in user_input:
        workload = "Cost Optimization"

    if workload == "Migration":

        agents = [
            "Cloud Architect",
            "Security Advisor",
            "Terraform Engineer",
            "FinOps Advisor"
        ]

    elif workload == "Terraform":

        agents = [
            "Terraform Engineer",
            "Cloud Architect"
        ]

    elif workload == "Cost Optimization":

        agents = [
            "FinOps Advisor"
        ]

    else:

        agents = [
            "Cloud Architect"
        ]

    return {

        "workload": workload,

        "confidence": 95,

        "agents": agents
    }