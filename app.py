import streamlit as st
from pathlib import Path

from workflow.workflow_manager import WorkflowManager

st.set_page_config(
    page_title="CloudPilot AI",
    page_icon="☁️",
    layout="wide"
)

st.title("☁️ CloudPilot AI")
st.caption("Enterprise Cloud Transformation Advisor")

requirement = st.text_area(
    "Customer Requirement",
    placeholder="Example: Migrate 50 VMware VMs to Azure with Disaster Recovery and Cost Optimization",
    height=180
)

if st.button("🚀 Analyze Requirement", use_container_width=True):

    workflow = WorkflowManager()

    status = st.status("Running AI Agents...", expanded=True)

    result = workflow.execute(requirement)

    status.write("🧠 Cloud Strategy Planner completed")
    status.write("🏗 Azure Solution Architect completed")
    status.write("🔐 Cloud Security Advisor completed")
    status.write("💻 Infrastructure Automation Engineer completed")
    status.update(
    label="✅ Analysis Completed",
    state="complete"
)

    planner = result.get("planner", {})
    architecture = result.get("architecture", {})
    security = result.get("security", {})
    finops = result.get("finops", {})

    st.divider()

    st.header("📊 Executive Dashboard")

    col1, col2, col3 = st.columns(3)

    col1.metric(
        "Priority",
        planner.get("priority", "N/A")
    )

    col2.metric(
        "Confidence",
        f"{planner['confidence']*100:.0f}%"
    )

    col3.metric(
        "AI Agents",
        len(planner["selected_agents"])
    )

    tab1, tab2, tab3, tab4, tab5 = st.tabs([
        "📊 Executive Summary",
        "🏗 Architecture",
        "🔐 Security",
        "💻 Infrastructure",
        "💰 FinOps"
    ])

    with tab1:
        st.subheader("Customer Requirement")
        st.info(requirement)

        st.subheader("Business Goal")
        st.success(planner["business_goal"])

        st.metric(
            "Priority",
            planner["priority"]
        )

        st.metric(
            "Confidence",
            f"{planner['confidence']*100:.0f}%"
        )

        st.write("### Selected AI Agents")

        for agent in planner["selected_agents"]:
            st.write(f"✅ {agent}")

    with tab2:
        with st.expander("Landing Zone"):
            st.write(architecture["landing_zone"])

        with st.expander("Network"):
            st.write(architecture["network_topology"])

        with st.expander("Compute"):
            st.write(architecture["compute"])

        with st.expander("Storage"):
            st.write(architecture["storage"])

        with st.expander("Backup"):
            st.write(architecture["backup"])

        with st.expander("Disaster Recovery"):
            st.write(architecture["disaster_recovery"])

    with tab3:
        with st.expander("Identity"):
            st.write(security["identity"])

        with st.expander("Network"):
            st.write(security["network_security"])

        with st.expander("Compliance"):
            st.write(security["compliance"])

        with st.expander("Recommendations"):
            st.write(security["recommendations"])


    with tab4:

        st.success("💻 Infrastructure Automation Engineer completed successfully")

    terraform_dir = Path("terraform")

    if terraform_dir.exists():

        st.subheader("Terraform Project")

        tf_files = sorted(terraform_dir.rglob("*.tf"))

        file_names = [
            str(file.relative_to(terraform_dir))
            for file in tf_files
        ]

        selected_file = st.selectbox(
            "Select Terraform File",
            file_names
        )

        selected_path = terraform_dir / selected_file

        st.code(
            selected_path.read_text(),
            language="terraform"
        )

    else:
        st.warning("Terraform project not found.")

    with tab5:

     st.subheader("💰 FinOps Recommendations")

    col1, col2 = st.columns(2)

    col1.metric(
        "Estimated Savings",
        finops.get("estimated_savings", "N/A")
    )

    col2.metric(
        "Monthly Cost",
        finops.get("estimated_monthly_cost", "N/A")
    )

    st.write("### Optimization Recommendations")

    st.success(
        finops.get("recommendations", "")
    )

    st.write("### Azure Hybrid Benefit")
    st.info(
        finops.get("azure_hybrid_benefit", "")
    )

    st.write("### Reservations")
    st.info(
        finops.get("reservations", "")
    )

    st.write("### Spot Instances")
    st.info(
        finops.get("spot_instances", "")
    )

    st.write("### Rightsizing")
    st.info(
        finops.get("rightsizing", "")
    )

    st.write("### Storage Optimization")
    st.info(
        finops.get("storage_optimization", "")
    )