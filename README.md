
# NAYANTRA

### Explainable AI for Diabetic Retinopathy & External Eye Abnormality Screening

> **An AI-assisted dual-modal eye screening platform designed for accessible, explainable and scalable screening in rural healthcare environments.**

---


### Smart India Hackathon 2026

| Detail | Information |
|---|---|
| **Problem Statement ID** | SIH26038 |
| **Problem Statement** | Explainable AI for Diabetic Retinopathy Screening in Rural India |
| **Theme** | MedTech / BioTech / HealthTech |
| **PS Category** | Software |
| **Team ID** | 159564 |
| **Team Name** | Nayantra |

## 1. About Nayantra

Nayantra is a proposed AI-assisted eye screening platform that combines **retinal fundus image analysis** and **external eye image analysis** into a unified screening workflow.

The system has two primary AI branches:

### Retinal / Fundus Screening

Designed for diabetic retinopathy screening:

* Image quality assessment
* Image enhancement
* Retinal structure analysis
* Lesion analysis
* DR severity classification
* Explainable AI
* Confidence estimation

### External Eye Screening

Designed for visible external eye abnormalities:

* Normal eye
* Red-eye / conjunctival abnormality
* Strabismus
* Eyelid swelling / stye
* Scleral discoloration

The outputs from both branches are combined through a **Multi-Modal AI Engine** to generate a structured screening result.

The final AI-assisted result is reviewed by an ophthalmologist before referral or follow-up.

> Nayantra is intended as a screening and decision-support prototype and not as a replacement for professional ophthalmological diagnosis.

---

# 2. Problem Statement

**SIH26038 — Explainable AI for Diabetic Retinopathy Screening in Rural India**

Diabetic retinopathy screening in rural environments faces several practical challenges:

### Limited Specialist Availability

Rural healthcare centres may have limited access to ophthalmologists. This makes large-scale manual screening difficult.

### Large Screening Requirement

A large diabetic population creates a requirement for scalable retinal screening.

### Variable Image Quality

Images captured using low-cost or portable imaging devices may contain:

* Blur
* Poor illumination
* Low contrast
* Incomplete field of view
* Noise

Poor-quality images can reduce the reliability of automated analysis.

### AI Interpretability

A classification result alone does not explain why a model produced a particular prediction.

For medical screening, visual evidence can help the ophthalmologist understand the AI output.

### Rural Connectivity

Continuous high-speed connectivity cannot always be assumed in rural screening environments.

### Specialist Workload

Large screening volumes can create referral and specialist-review bottlenecks.

---

# 3. Proposed Solution

Nayantra addresses these challenges through a **quality-aware, explainable, dual-modal AI screening pipeline**.

The high-level architecture is:

```text
Patient Registration
        ↓
Select Screening Mode
        ↓
 ┌───────────────┬──────────────────┐
 │               │                  │
 ▼               ▼                  │
Fundus Image   External Eye Image   │
 │               │                  │
 ▼               ▼                  │
Quality Check  Quality Check         │
 │               │                  │
 ▼               ▼                  │
Preprocessing  Preprocessing         │
 │               │                  │
 ▼               ▼                  │
DR Analysis    External Eye Analysis │
 │               │                  │
 └───────────────┴──────────────────┘
                 ↓
        Multi-Modal AI Engine
                 ↓
          Risk Assessment
                 ↓
          Explainable AI
                 ↓
       Structured Clinical Report
                 ↓
       Ophthalmologist Review
                 ↓
        Referral / Follow-up
```

---

# 4. What Makes Nayantra Different

The project is not limited to a simple DR classifier.

It combines several components into one workflow:

### 1. Quality-Aware AI

The system checks whether an image is suitable for analysis before relying on the AI result.

### 2. Dual-Modal Screening

It considers both:

**Fundus image → DR screening**

and

**External eye image → visible eye-abnormality screening**

### 3. Explainable AI

The system provides:

* Grad-CAM
* Heatmaps
* Lesion evidence
* Confidence information

instead of only returning a class label.

### 4. Human-in-the-Loop

The ophthalmologist remains part of the final decision process.

### 5. Rural Deployment Consideration

The architecture considers:

* Low connectivity
* Edge/local processing
* Centralized processing
* Specialist availability

### 6. System-Level Simulation

MATLAB/Simulink can be used to model the rural screening workflow and study:

* Patient throughput
* Waiting time
* Network bandwidth
* AI processing capacity
* Specialist workload
* Referral backlog

---

# 5. Complete Patient Workflow

## Step 1 — Patient Registration

The healthcare worker enters basic information such as:

* Patient ID
* Age
* Gender
* Basic details where required

---

## Step 2 — Select Screening Mode

The system allows the screening input to be selected.

```text
Fundus Screening
       OR
External Eye Screening
       OR
Both
```

This allows the platform to operate as a dual-modal screening system.

---

## Step 3 — Image Acquisition

### Fundus

A retinal/fundus image is captured using a fundus imaging device.

### External Eye

An external eye image is captured for visible abnormalities.

---

# 6. Fundus / Diabetic Retinopathy Module

The fundus module focuses on automated DR screening.

```text
Fundus Image
     ↓
Image Quality Assessment
     ↓
Enhancement
     ↓
Retinal Structure Analysis
     ↓
Lesion Analysis
     ↓
DR Classification
     ↓
Explainable AI
```

---

## 6.1 Fundus Image Quality Assessment

Before classification, the image is checked for usability.

The quality pipeline considers:

### Focus

Determines whether the retinal structures are sufficiently sharp.

### Blur

Detects images where motion or focus problems may affect analysis.

### Illumination

Checks whether the retinal image has uneven or insufficient lighting.

### Contrast

Determines whether retinal features are sufficiently distinguishable.

### Field of View

Checks whether enough of the retina is visible.

The output can be conceptually represented as:

```text
Image
 ↓
Quality Analysis
 ↓
 ┌───────────────┐
 │ Good Quality  │ → Continue
 └───────────────┘

 ┌────────────────┐
 │ Poor Quality   │ → Recapture / Flag
 └────────────────┘
```

---

# 7. Image Preprocessing

The preprocessing stage improves image consistency before AI analysis.

Techniques include:

* CLAHE
* Denoising
* Noise filtering
* Illumination correction
* Normalization
* Resizing
* Standardization

Example:

```text
Raw Image
    ↓
Noise Reduction
    ↓
CLAHE
    ↓
Illumination Correction
    ↓
Normalization
    ↓
Enhanced Image
```

The same general preprocessing philosophy can be adapted for both fundus and external-eye images.

---

# 8. Retinal Structure Analysis

The fundus branch can analyse relevant retinal structures.

Potential structures include:

* Retinal vessels
* Optic disc
* Fovea
* Other retinal regions relevant to screening

Computer vision and segmentation techniques can be used to identify these structures.

---

# 9. Retinal Lesion Analysis

The system can analyse clinically relevant retinal lesions such as:

* Microaneurysms
* Hemorrhages
* Exudates

The lesion-analysis component is intended to provide additional visual evidence alongside the DR classification.

---

# 10. DR Classification

The DR classifier follows five severity categories:

| Grade | Classification   |
| ----- | ---------------- |
| 0     | No DR            |
| 1     | Mild NPDR        |
| 2     | Moderate NPDR    |
| 3     | Severe NPDR      |
| 4     | Proliferative DR |

The model can be developed using transfer-learning architectures such as:

* ResNet-18
* EfficientNet

Model performance is evaluated using appropriate classification metrics rather than relying only on accuracy.

---

# 11. External Eye Abnormality Module

The second major branch is designed for visible external eye abnormalities.

```text
External Eye Image
        ↓
Quality Assessment
        ↓
Preprocessing
        ↓
Feature Extraction
        ↓
Classification
        ↓
External Eye Finding
```

The planned five-class classification is:

```text
0 → Normal
1 → Red-eye / Conjunctival Abnormality
2 → Strabismus
3 → Eyelid Swelling / Stye
4 → Scleral Discoloration
```

This module complements the retinal branch rather than replacing it.

---

# 12. Multi-Modal AI Engine

The results from both branches are combined.

```text
             Fundus Model
                  ↓
               DR Grade
                  │
                  │
                  ├──────────┐
                  │          │
                  ▼          ▼
             Multi-Modal AI Engine
                  ▲          │
                  │          ▼
                  │      Risk Level
                  │
          External Eye Model
                  ↑
          Eye Abnormality
```

Possible combined information:

* DR grade
* External-eye finding
* Confidence score
* Risk information
* Visual evidence
* Explainable AI output

The multi-modal component is intended to provide a more complete screening view of the patient's eye-related findings.

---

# 13. Explainable AI

Nayantra uses Explainable AI to make model outputs more interpretable.

## Grad-CAM

Grad-CAM can generate a heatmap showing image regions that contributed to a CNN prediction.

```text
Original Image
      ↓
AI Model
      ↓
Prediction
      ↓
Grad-CAM
      ↓
Heatmap
      ↓
Visual Evidence
```

For the fundus branch, this can help highlight regions associated with the model's prediction.

For applicable external-eye models, visual explanations can similarly support interpretation.

---

# 14. Confidence Score

The system can provide a confidence score along with the model prediction.

Example:

```text
DR Grade: Moderate NPDR
Confidence: 91%
```

The confidence value should be presented as a model output and not interpreted as a guarantee of clinical correctness.

---

# 15. TLBO-Based Optimization

Teaching-Learning-Based Optimization (TLBO) is included as an optimization component.

It can be used to search for suitable model hyperparameters.

Potential parameters include:

* Learning rate
* Batch size
* Number of layers
* Filters
* Dropout
* Kernel size

The conceptual process is:

```text
Model Configuration
       ↓
TLBO Search
       ↓
Candidate Parameters
       ↓
Model Training
       ↓
Validation Metric
       ↓
Parameter Selection
       ↓
Optimized Configuration
```

TLBO is therefore positioned as a **model-development optimization layer**, not as a patient-level workflow stage.

---

# 16. Model Architecture

The proposed AI architecture can include:

### EfficientNet

Used for feature extraction and classification.

### U-Net

Used for segmentation tasks.

Potential segmentation targets include retinal structures and lesions.

### CLV

Used as part of the proposed feature-learning architecture.

### TLBO

Used for hyperparameter optimization.

Conceptually:

```text
                  Input Image
                      ↓
                Preprocessing
                      ↓
       ┌──────────────┼──────────────┐
       ↓              ↓              ↓
 EfficientNet       U-Net           CLV
       │              │              │
       │        Segmentation     Feature Learning
       └──────────────┼──────────────┘
                      ↓
                TLBO Optimization
                      ↓
                Optimized Model
                      ↓
              Classification
```

---

# 17. Datasets

## APTOS 2019

Used for diabetic retinopathy severity classification.

```text
https://www.kaggle.com/c/aptos2019-blindness-detection
```

---

## IDRiD

Indian Diabetic Retinopathy Image Dataset.

Useful for:

* DR analysis
* Lesion annotations
* Retinal structures

```text
https://ieeedataport.org/open-access/indian-diabetic-retinopathy-image-dataset-idrid
```

---

## DRIVE

Digital Retinal Images for Vessel Extraction.

Useful for retinal vessel analysis.

```text
https://drive.grand-challenge.org/
```

---

## Messidor-2

Used as an additional retinal dataset for validation.

```text
https://www.adcis.net/en/third-party/messidor2/
```

---

## External Eye Dataset

The external-eye branch requires appropriate labelled datasets for the five target categories.

The final dataset selection, licensing and class distribution should be documented once finalized.

### Dataset Download & Setup

The complete datasets are **not included in this GitHub repository** because of their large size and dataset licensing/distribution considerations.

#### APTOS 2019

Download the APTOS 2019 dataset directly from Kaggle:

**Dataset:** https://www.kaggle.com/c/aptos2019-blindness-detection

After downloading and extracting it, place the required files in the project dataset directory:

```text
data/
└── aptos2019/
    ├── train.csv
    ├── test.csv
    ├── train_images/
    └── test_images/
```

Setup steps:

1. Download the dataset from the original source.
2. Extract the downloaded files.
3. Create the required dataset directory.
4. Place `train.csv`, `test.csv`, `train_images/`, and `test_images/` in the corresponding location.
5. Run the MATLAB preprocessing and training scripts.

> **Note:** The 2 GB-class dataset is intentionally not stored in GitHub. Users should download it directly from the original dataset provider.

---

# 18. Cross-Dataset Validation

A major part of the proposed validation strategy is testing model robustness across different datasets.

For example:

```text
APTOS
   ↓
Training / Validation
   ↓
Model
   ↓
IDRiD / Messidor-2
   ↓
External Validation
```

This can help identify performance changes caused by:

* Different cameras
* Different image quality
* Different populations
* Different acquisition conditions
* Dataset-specific characteristics

---

# 19. Model Evaluation

The models can be evaluated using:

### Classification Metrics

* Accuracy
* Precision
* Recall
* F1-score

### Medical Screening Metrics

* Sensitivity
* Specificity

### Additional Evaluation

* ROC-AUC
* Confusion matrix
* Class-wise performance
* Macro-average metrics
* Cross-dataset performance

For imbalanced medical datasets, class-wise and macro-level metrics are especially important.

---

# 20. Structured Clinical Report

The final system generates a structured screening report.

Possible sections:

```text
Patient Information
       ↓
Image Quality
       ↓
DR Result
       ↓
External Eye Result
       ↓
Confidence
       ↓
Visual Evidence
       ↓
Risk Information
       ↓
Referral Recommendation
```

Example:

```text
NAYANTRA SCREENING REPORT

Patient ID: XXXXX

Fundus Screening
DR Grade: Grade 2
Confidence: XX%

External Eye Screening
Finding: Red-eye / Conjunctival Abnormality
Confidence: XX%

Image Quality
Status: Good

Explainable Evidence
Grad-CAM: Available
Lesion Evidence: Available

Recommendation
Ophthalmologist Review
```

---

# 21. Human-in-the-Loop Clinical Validation

Nayantra does not treat the AI result as the final diagnosis.

The workflow is:

```text
AI Screening
     ↓
AI Result
     ↓
Structured Report
     ↓
Ophthalmologist
     ↓
Confirm / Modify / Reject
     ↓
Final Referral / Follow-up
```

This keeps the medical decision with the qualified healthcare professional.

---

# 22. Rural Healthcare Deployment

The system is designed around a PHC/rural screening scenario.

A possible deployment model is:

```text
Rural PHC
   ↓
Image Capture
   ↓
Local Quality Check
   ↓
AI Screening
   ↓
Structured Report
   ↓
Network
   ↓
Ophthalmologist
   ↓
Final Review
```

Where connectivity is limited, local or edge processing can reduce dependence on continuous high-speed internet.

---

# 23. MATLAB Implementation

MATLAB can be used for:

* Image processing
* Deep-learning experimentation
* Model training
* Transfer learning
* Model evaluation
* Confusion matrices
* Visualization
* Performance analysis

The project has also explored **ResNet-18 transfer learning** for DR classification.

---

# 24. Simulink Implementation

Simulink is used at the **system/workflow level**, not as a replacement for the medical AI model.

A rural screening simulation can model:

```text
Patients
   ↓
Image Acquisition
   ↓
Network
   ↓
AI Processing
   ↓
Referral Queue
   ↓
Ophthalmologist
   ↓
Final Review
```

Possible simulation parameters:

* Patients/day
* Images/day
* Image size
* Bandwidth
* AI processing time
* Number of ophthalmologists
* Review time

Possible outputs:

* Waiting time
* Throughput
* Network utilization
* AI utilization
* Specialist utilization
* Referral backlog

This helps evaluate whether the proposed workflow can scale from a small screening centre toward district-level deployment.

---

# 25. Hardware / Edge Prototype

A hardware-assisted implementation can be developed using a low-cost camera and edge controller.

A realistic architecture is:

```text
Fundus / External Eye Camera
          ↓
Image Capture
          ↓
ESP32 / Edge Controller
          ↓
Wi-Fi / USB / Local Transfer
          ↓
Edge Computer / Laptop / Server
          ↓
AI Inference
          ↓
Explainable Result
          ↓
Healthcare Worker
```

The important architectural point is that an ESP32 can handle:

* Camera/device control
* Data transfer
* Basic preprocessing/control
* Communication

while computationally heavy models such as EfficientNet/U-Net can run on:

* Laptop
* Edge computer
* GPU system
* Local server
* Cloud server

depending on deployment requirements.

---

# 26. Backend Architecture

The proposed backend uses a REST-based architecture.

```text
Frontend
   ↓
FastAPI
   ↓
AI Service
   ├── Image Quality
   ├── DR Model
   ├── External Eye Model
   ├── Grad-CAM
   └── Report Generator
   ↓
Database
```

Potential API operations include:

```text
POST /screen/fundus
POST /screen/external-eye
POST /screen/multimodal
POST /quality-check
POST /gradcam
GET  /report/{id}
```

The final API structure can evolve during implementation.

---

# 27. Frontend

The interface is intended to provide a simple workflow for healthcare workers.

Potential screens:

### Patient Registration

Basic patient information.

### Screening Mode

```text
Fundus
External Eye
Both
```

### Image Upload / Capture

Upload or capture the required image.

### AI Screening

Show processing status.

### Result

Display:

* DR grade
* External-eye finding
* Confidence
* Image quality
* Visual evidence

### Clinical Report

Generate structured screening information.

### Referral

Show recommendation for specialist review/follow-up.

---

# 28. Technology Stack

| Layer            | Technologies                            |
| ---------------- | --------------------------------------- |
| Core Development | Python, MATLAB                          |
| Simulation       | MATLAB, Simulink                        |
| Image Processing | OpenCV, MATLAB Image Processing Toolbox |
| Enhancement      | CLAHE, denoising, normalization         |
| Computer Vision  | Retinal structure & lesion analysis     |
| Deep Learning    | ResNet-18, EfficientNet, U-Net          |
| Optimization     | TLBO                                    |
| Explainability   | Grad-CAM, heatmaps                      |
| Backend          | FastAPI, REST API                       |
| Database         | PostgreSQL / suitable database          |
| Frontend         | Web dashboard                           |
| Deployment       | Local / Edge / Server                   |
| Hardware         | ESP32 + camera-based prototype          |
| Version Control  | Git + GitHub                            |

---

# 29. Project Structure

```text
Nayantra/
│
├── data/
│   ├── fundus/
│   └── external_eye/
│
├── preprocessing/
│   ├── quality/
│   ├── enhancement/
│   └── normalization/
│
├── models/
│   ├── dr/
│   ├── external_eye/
│   ├── segmentation/
│   └── optimization/
│
├── explainability/
│   ├── gradcam/
│   └── heatmaps/
│
├── backend/
│   ├── main.py
│   ├── api/
│   ├── services/
│   └── schemas/
│
├── frontend/
│
├── matlab/
│
├── simulink/
│
├── hardware/
│
├── notebooks/
│
├── tests/
│
├── reports/
│
├── requirements.txt
├── .gitignore
├── LICENSE
└── README.md
```

---

# 30. Development Status

## Implemented / Experimented

* Dataset preparation
* Fundus image preprocessing
* ResNet-18 transfer learning experimentation
* DR classification workflow
* Model evaluation
* Confusion matrix analysis
* Explainability concept
* Complete dual-modal workflow design
* MATLAB-based experimentation
* Rural Simulink workflow concept

## In Development

* External eye classification
* EfficientNet pipeline
* U-Net segmentation
* Grad-CAM integration
* Multi-modal fusion
* TLBO optimization
* FastAPI backend
* Structured report generation
* Web interface

## Planned

* Hardware prototype
* Edge deployment
* Cross-dataset validation
* Complete end-to-end integration
* Rural workflow simulation
* Deployment testing

This distinction is important because the GitHub repository should not present planned components as already completed.

---

# 31. Challenges and Proposed Solutions

| Challenge            | Proposed Approach                     |
| -------------------- | ------------------------------------- |
| Poor image quality   | Quality gate + enhancement            |
| Blur                 | Focus/quality assessment              |
| Uneven illumination  | Illumination correction               |
| Low contrast         | CLAHE                                 |
| Black-box prediction | Grad-CAM + visual evidence            |
| Dataset variation    | Cross-dataset validation              |
| Low connectivity     | Local/edge + centralized architecture |
| Specialist shortage  | AI-assisted preliminary screening     |
| High patient volume  | Workflow modelling + prioritization   |
| AI reliability       | Human-in-the-loop validation          |

---

# 32. Expected Impact

## Patients

* Improved access to screening
* Earlier identification of potential eye complications
* Reduced unnecessary travel for preliminary screening

## Healthcare Workers

* Simple screening workflow
* Automated image quality feedback
* Structured reports
* AI-assisted findings

## Ophthalmologists

* Organized screening information
* Visual evidence
* DR severity information
* Potential referral prioritization

## Healthcare System

* PHC-level screening support
* Better utilization of specialist capacity
* Rural tele-screening
* District-level capacity planning

---

# 33. Future Scope

Future development can include:

* Portable fundus cameras
* Low-cost external-eye imaging
* Edge AI
* Offline-first architecture
* Model compression
* Larger multi-centre datasets
* More external-eye conditions
* Improved lesion segmentation
* District-level deployment
* State-level deployment
* Integration with healthcare information systems
* Continuous model monitoring

---

# 34. Limitations

The current project has several limitations.

### Dataset Limitations

Public datasets may not fully represent all rural acquisition conditions.

### Camera Variation

Different cameras can produce different image characteristics.

### External Eye Data

The external-eye module requires sufficiently representative and appropriately labelled datasets.

### Clinical Validation

A research prototype requires extensive clinical validation before real-world medical deployment.

### Connectivity

Actual rural connectivity conditions can vary significantly by location.

### Hardware

Low-cost hardware may have limitations in image quality, illumination and computational capability.

---

# 35. Research References

### APTOS 2019

Diabetic Retinopathy Blindness Detection.

[https://www.kaggle.com/c/aptos2019-blindness-detection](https://www.kaggle.com/c/aptos2019-blindness-detection)

### IDRiD

Indian Diabetic Retinopathy Image Dataset.

[https://ieeedataport.org/open-access/indian-diabetic-retinopathy-image-dataset-idrid](https://ieeedataport.org/open-access/indian-diabetic-retinopathy-image-dataset-idrid)

### DRIVE

Digital Retinal Images for Vessel Extraction.

[https://drive.grand-challenge.org/](https://drive.grand-challenge.org/)

### Messidor-2

Diabetic Retinopathy Dataset.

[https://www.adcis.net/en/third-party/messidor2/](https://www.adcis.net/en/third-party/messidor2/)

### Grad-CAM

Selvaraju et al., *Grad-CAM: Visual Explanations from Deep Networks via Gradient-based Localization.*

[https://arxiv.org/abs/1610.02391](https://arxiv.org/abs/1610.02391)

### U-Net

Ronneberger et al., *U-Net: Convolutional Networks for Biomedical Image Segmentation.*

[https://arxiv.org/abs/1505.04597](https://arxiv.org/abs/1505.04597)

---

# 36. Installation

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/NAYANTRA.git

cd Nayantra-Explainable-AI-Eye-Screening

python -m venv .venv
```

### Windows

```bash
.venv\Scripts\activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

---

# 37. Running the Backend

Once the FastAPI service is configured:

```bash
uvicorn backend.main:app --reload
```

The API can expose screening services for the AI pipeline.

---

# 38. GitHub Development Workflow

Recommended branches:

```text
main
│
├── development
├── feature/image-quality
├── feature/dr-classification
├── feature/external-eye
├── feature/segmentation
├── feature/gradcam
├── feature/tlbo
├── feature/backend
├── feature/frontend
├── feature/simulink
└── feature/hardware
```

Example:

```bash
git checkout -b feature/external-eye

git add .

git commit -m "Add external eye screening module"

git push origin feature/external-eye
```

---

# 39. License

The repository can use the **MIT License**, subject to the team's final decision regarding ownership and distribution.

A separate `LICENSE` file should be added to the repository.

---

# 40. Medical Disclaimer

Nayantra is a research and prototype system for AI-assisted eye screening.

It is **not a medical diagnostic device** and should not be used as a substitute for professional medical examination.

AI predictions may contain errors.

Final diagnosis, treatment and referral decisions must be made by qualified healthcare professionals.

---

# 43. Project Vision

Nayantra aims to move from:

```text
Image Capture
      ↓
AI Analysis
      ↓
Explainable Evidence
      ↓
Human Validation
      ↓
Timely Referral
```
