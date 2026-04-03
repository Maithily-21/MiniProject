import streamlit as st
import requests
import io
import os
from PIL import Image

# ─── Configuration ────────────────────────────────────────────────────────────
API_BASE_URL = "http://localhost:8000"

st.set_page_config(
    page_title="SmartDent AI - Backend Tester",
    page_icon="🦷",
    layout="wide",
)

# ─── Sidebar: Logo & Info ──────────────────────────────────────────────────────
st.sidebar.title("🦷 SmartDent AI")
st.sidebar.markdown("---")
st.sidebar.info("Model Testing Mode: Authentication disabled for direct analysis.")

# ─── Main content ─────────────────────────────────────────────────────────────
st.title("Intraoral Image Analysis Dashboard")
st.markdown("Upload a dental image to run the full AI pipeline (Segmentation, Alignment, Symmetry, Pathology).")

uploaded_file = st.file_uploader("Choose an intraoral image...", type=["jpg", "jpeg", "png", "webp", "bmp"])

if uploaded_file is not None:
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Source Image")
        image = Image.open(uploaded_file)
        st.image(image, width="stretch")

    if st.button("Run AI Analysis"):
        with st.spinner("Processing image through AI pipeline..."):
            # Prepare headers (no auth token needed now)
            files = {"file": (uploaded_file.name, uploaded_file.getvalue(), uploaded_file.type)}
            
            try:
                resp = requests.post(f"{API_BASE_URL}/analyze", files=files)
                
                if resp.status_code == 200:
                    data = resp.json()
                    st.session_state.last_result = data
                    st.success("Analysis Complete!")
                else:
                    st.error(f"Analysis failed: {resp.json().get('detail', 'Unknown error')}")
            except Exception as e:
                st.error(f"Connection error: {e}")

    # ─── Results Display ─────────────────────────────────────────────────────
    if "last_result" in st.session_state:
        res = st.session_state.last_result
        
        st.markdown("---")
        st.header("Analysis Results")
        
        # Row 1: Visualisations & Summary
        v_col1, v_col2 = st.columns(2)
        with v_col1:
            st.subheader("Cosmetic Analysis")
            # Logic for Cosmetic Recommendations
            align = res.get('alignment_score', 0)
            symm  = res.get('symmetry_score', 0)
            stain = res.get('staining_score', 0)
            st_res = res.get('staining_result', 'N/A')
            
            if align < 70:
                st.warning("⚠️ **Alignment Tip:** Your current score suggests potential crowding or misalignment. Consider an orthodontic consultation or clear aligners (Invisalign).")
            elif align < 90:
                st.info("✨ **Cosmetic Tip:** Minor alignment detected. Cosmetic bonding or veneers could further enhance your smile symmetry.")
            else:
                st.success("🌟 **Professional Grade:** Your dental alignment is exceptional!")

            if symm < 70:
                st.warning("⚖️ **Symmetry Tip:** A lower symmetry score often indicates slight shifting. An occlusal check is recommended to ensure a balanced bite.")
            
            st.markdown(f"**Surface Analysis:** {st_res}")
            if stain > 10:
                st.error("🦷 **Hygiene Alert:** Significant staining or plaque detected. Professional scaling and polishing is recommended to restore enamel purity.")
        
        with v_col2:
            st.subheader("Clinical Summary")
            
            st.markdown("**Pathology Check:**")
            cav_status = "🔴 Detected" if res['cavity_result'] == "Detected" else "🟢 Healthy"
            gum_status = "🔴 Review Needed" if res['gum_disease_result'] != "Healthy" else "🟢 Healthy"
            
            st.write(f"Cavity Status: **{cav_status}**")
            st.write(f"Gum Health: **{gum_status}**")

        # Row 2: Detailed Recommendations
        st.markdown("---")
        i_col1, i_col2 = st.columns(2)
        
        with i_col1:
            st.subheader("Health Findings")
            issues = res.get("report", {}).get("issues", [])
            if issues:
                for issue in issues:
                    st.error(issue)
            else:
                st.success("No clinical pathologies detected.")
        
        with i_col2:
            st.subheader("Action Plan")
            suggestions = res.get("report", {}).get("suggestions", [])
            if suggestions:
                for sug in suggestions:
                    st.info(sug)
            else:
                st.write("Maintain your current oral hygiene routine.")

# ─── Footer ───────────────────────────────────────────────────────────────────
st.markdown("---")
st.caption("SmartDent AI Backend Tester | Powered by FastAPI, PyTorch & Streamlit")
