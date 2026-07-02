
from agents.planner import analyze_request
import streamlit as st

st.set_page_config(
    page_title="CloudPilot AI",
    page_icon="☁️",
    layout="wide"
)

st.title("☁️ CloudPilot AI")
st.markdown("### Autonomous Multi-Agent Cloud Transformation Advisor")

st.divider()

requirement = st.text_area(
    "Describe your Cloud Requirement",
    height=180,
    placeholder="""
Example:

Migrate 25 VMware VMs to Azure.

Requirements:
- High Availability
- Disaster Recovery
- Cost Optimized
- Secure Landing Zone
"""
)

uploaded_file = st.file_uploader(
    "Upload Inventory (CSV)",
    type=["csv"]
)

if st.button("🚀 Generate Solution", use_container_width=True):

    result = analyze_request(requirement)

    st.success("Planner Agent Analysis Completed")

    st.write("### Workload")

    st.info(result["workload"])

    st.write("### Confidence")

    st.progress(result["confidence"]/100)

    st.write(f'{result["confidence"]}%')

    st.write("### Selected Agents")

    for agent in result["agents"]:

        st.success(agent)