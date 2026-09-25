# Nayantra – Explainable AI Eye Screening System

Nayantra is a dual-modal AI-assisted eye screening system designed to support eye screening in rural healthcare environments.

The system combines:

- Retinal fundus image analysis for Diabetic Retinopathy (DR)
- External eye image analysis for visible eye abnormalities
- Image quality assessment and enhancement
- Deep learning-based classification
- Lesion and retinal structure analysis
- Explainable AI using Grad-CAM
- Multi-modal risk assessment
- Structured clinical screening reports
- Ophthalmologist validation and referral support
- MATLAB/Simulink-based workflow and scalability simulation

> **Nayantra is designed as an AI-assisted screening and decision-support system. Final clinical decisions remain with qualified ophthalmologists.**

---

## Problem Statement

**SIH26038 – Explainable AI for Diabetic Retinopathy Screening in Rural India**

Rural healthcare centres may have limited access to ophthalmologists and specialist screening facilities. Nayantra aims to provide an AI-assisted preliminary screening workflow that can help identify patients requiring further ophthalmological evaluation.

---

## Key Features

### 1. Dual-Modal Eye Screening

Nayantra supports two complementary image inputs:

- **Fundus Image → Diabetic Retinopathy Screening**
- **External Eye Image → Visible Eye Abnormality Screening**

### 2. Image Quality Assessment

The system evaluates image quality before AI analysis using:

- Focus
- Illumination
- Contrast
- Field of View
- Blur detection

Poor-quality images can be flagged for enhancement or recapture.

### 3. Image Preprocessing

The preprocessing pipeline includes:

- CLAHE
- Denoising
- Normalization
- Illumination correction
- Image resizing/standardization

### 4. Diabetic Retinopathy Analysis

Fundus images are analysed for DR severity using the ICDR grading scale:

```text
Grade 0 – No DR
Grade 1 – Mild NPDR
Grade 2 – Moderate NPDR
Grade 3 – Severe NPDR
Grade 4 – Proliferative DR
