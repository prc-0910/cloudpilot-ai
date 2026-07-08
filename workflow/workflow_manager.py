from agents.planner import PlannerAgent
from agents.architect import ArchitectAgent
from agents.security import SecurityAgent


class WorkflowManager:

    def __init__(self):

        self.planner = PlannerAgent()
        self.architect = ArchitectAgent()
        self.security = SecurityAgent()

    def execute(self, requirement: str):

        results = {}

        # Step 1
        plan = self.planner.analyze(requirement)

        results["planner"] = plan

        # Step 2
        if "Cloud Architect" in plan["selected_agents"]:

            architecture = self.architect.design(requirement)

            results["architecture"] = architecture

        # Step 3
        if "Security Advisor" in plan["selected_agents"]:

            security = self.security.review(
                requirement,
                architecture
            )

            results["security"] = security
        

        return results