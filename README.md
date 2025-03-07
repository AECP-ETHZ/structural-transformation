## **Structural Transformation: Agriculture and Economic Growth**  

This readme file was generated on **[2025-03-07]** by **[Andrea Fürholz]**.  

### **About this project**  
This repository analyzes the structural transformation in agriculture by examining the relationship between GDP per capita, agricultural GDP share, and agricultural employment. The dataset is sourced from the **World Bank Database**, covering the years **1960–2023**. However, due to many missing values before **1990**, data has been filtered accordingly.  

### **Data sources**  
The following datasets from the **World Bank** have been used in this analysis:  
- **Employment in agriculture (% of total employment)**  
  [World Bank Employment Data](https://databank.worldbank.org/reports.aspx?source=2&series=SL.AGR.EMPL.ZS&country=)  
- **GDP per capita (constant 2015 US$)**  
  [World Bank GDP Data](https://databank.worldbank.org/source/world-development-indicators/Series/NY.GDP.PCAP.KN)  
- **Agricultural GDP (% of total GDP)**  
  [World Bank Agricultural GDP Data](https://databank.worldbank.org/reports.aspx?source=2&series=NV.AGR.TOTL.ZS&country=)  

### **Data Processing**  
The analysis follows these key steps:  
1. **Data Cleaning & Filtering**:  
   - Removal of irrelevant country aggregations.  
   - Filtering out **NA values** before 1990.  
2. **Data Transformation**:  
   - Converting data into **long format** for time-series analysis.  
   - Merging datasets based on **Country Name** and **Year**.  
   - Computing **log GDP per capita** and the difference between agricultural GDP share and employment share.  
3. **Data Visualization**:  
   - Creating **static and interactive scatter plots** using **ggplot2** and **Plotly**.  
   - Showing structural changes in agriculture relative to economic growth.  

### **Results & Interpretation**  
The results illustrate how agricultural employment and GDP share **decline** as GDP per capita increases, consistent with theories of structural transformation. These insights are valuable for understanding **economic development patterns** and shaping **agricultural policies**.  

### **Usage**  
- The repository contains **R scripts** for data processing and visualization.  
- The final output includes **static (PNG) and interactive (HTML) visualizations**.  
- Users can modify the scripts to analyze specific country trends.  



