from agents.planner import PlannerAgent

planner = PlannerAgent()

result = planner.analyze(
    "Migrate 50 VMware VMs to Azure with Disaster Recovery and Cost Optimization."
)

print(result)