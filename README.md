# 🦁 Lion Resource Selection Function (RSF) Modelling

This project models **habitat selection behavior of lions** using GPS collar data, random background points, and a habitat classification raster. We apply a **logistic regression–based RSF** to identify habitat preferences across a specified home range.

---

## 📍 Study Area

- **Location**: Angama, Kenya
- **Coordinate Reference System**: UTM Zone 36S (EPSG:32736)
- **Dataset**: GPS tracking from collared lions, habitat raster derived from remote sensing, and shapefile of lion home range

---

## 🎯 Objectives

- Generate random background points within the home range of a collared lion
- Extract habitat characteristics from a classified raster map
- Fit a **weighted logistic regression RSF model**
- Visualize proportional habitat use versus availability

---

## 🧩 Data Inputs

| Type       | File                             | Description                              |
|------------|----------------------------------|------------------------------------------|
| GPS Points | `ANGaF3_42559_Complete_RSF.csv`  | Lion location data with latitude/longitude |
| Polygon    | `ANGaF3_42559.shp`               | Lion home range polygon (100% MCP)        |
| Raster     | `habitatfinal.tif`               | Habitat classification raster (5 classes) |

---

## 🔬 Method Overview

1. **Preprocessing**  
   - Convert GPS points to `sf` object  
   - Reproject all spatial data to UTM (EPSG:32736)

2. **Background Sampling**  
   - Randomly generate ~12,000 points within the lion's home range  
   - Label used (GPS) vs. available (random) data

3. **Covariate Extraction**  
   - Extract raster values at point locations  
   - Recode habitat types as factors: `Water`, `Open`, `Semi-closed`, `Closed`, `Agriculture`

4. **Modeling**  
   - Fit a logistic regression (`glm`) weighted RSF model  
   - Response: Used vs. Available  
   - Predictor: Habitat type  
   - Weight: 1 for used, 5000 for available

5. **Visualization**  
   - Bar plot comparing proportional use vs. availability by habitat type

---
