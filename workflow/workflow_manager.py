from agents.planner import PlannerAgent
from agents.architect import ArchitectAgent
from agents.security import SecurityAgent
from agents.finops import FinOpsAgent


class WorkflowManager:

    def __init__(self):

        self.planner = PlannerAgent()
        self.architect = ArchitectAgent()
        self.security = SecurityAgent()
        self.finops = FinOpsAgent()

    def execute(self, requirement: str):

        results = {}

        # Planner
        plan = self.planner.analyze(requirement)
        results["planner"] = plan

        # Architecture
        architecture = None

        if "Cloud Architect" in plan["selected_agents"]:

            architecture = self.architect.design(requirement)

            results["architecture"] = architecture

        # Security
        if (
            "Security Advisor" in plan["selected_agents"]
            and architecture is not None
        ):

            security = self.security.review(
                requirement,
                architecture
            )

            results["security"] = security


        # FinOps
        if "FinOps Advisor" in plan["selected_agents"] and architecture is not None:

            finops = self.finops.analyze(requirement, architecture)

            results["finops"] = finops

        return results