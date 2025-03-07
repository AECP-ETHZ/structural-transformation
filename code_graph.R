#Bibliotheken laden 
library(readr)
library(readxl)
library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(plotly)
library(htmlwidgets)
library(dplyr)
################################################################################
#Daten laden 
employment <- read_excel("employment.xlsx", sheet = 1)
gdp <- read_excel("gdp_percaptia.xlsx", sheet = 1)
agrar_gdp <- read_excel("agrar_gdp.xlsx", sheet = 1)

employment_filtered <- employment %>%  select(-c("Series Name", "Series Code" , "Country Code"))
colnames(employment_filtered) <- str_replace(colnames(employment_filtered), "\\[YR[0-9]{4}\\]", "")

agrar_gdp_filtered <- agrar_gdp %>%  select(-c("Series Name", "Series Code" , "Country Code"))
colnames(agrar_gdp_filtered) <- str_replace(colnames(employment_filtered), "\\[YR[0-9]{4}\\]", "")


remove_countries <- c("Africa Eastern and Southern", 
                      "Africa Western and Central", 
                      "Arab World", 
                      "Caribbean small states",
                      "Central Europe and the Baltics", 
                      "Early-demographic dividend",
                      "East Asia & Pacific",
                      "East Asia & Pacific (excluding high income)",
                      "East Asia & Pacific (IDA & IBRD countries)",
                      "Euro area",
                      "Europe & Central Asia",
                      "Europe & Central Asia (excluding high income)",
                      "Europe & Central Asia (IDA & IBRD countries)",
                      "European Union",
                      "Fragile and conflict affected situations",
                      "Heavily indebted poor countries (HIPC)",
                      "High income",
                      "IBRD only",
                      "IDA & IBRD total",
                      "IDA blend",
                      "IDA only",
                      "IDA total",
                      "Late-demographic dividend",
                      "Latin America & Caribbean",
                      "Latin America & Caribbean (excluding high income)",
                      "Latin America & the Caribbean (IDA & IBRD countries)",
                      "Least developed countries: UN classification",
                      "Low & middle income",
                      "Low income",
                      "Lower middle income",
                      "Middle East & North Africa",
                      "Middle East & North Africa (excluding high income)",
                      "Middle East & North Africa (IDA & IBRD countries)",
                      "Middle income",
                      "North America",
                      "Not classified",
                      "OECD members",
                      "Other small states",
                      "Pacific island small states",
                      "Post-demographic dividend",
                      "Pre-demographic dividend",
                      "Small states",
                      "South Asia",
                      "South Asia (IDA & IBRD)",
                      "Sub-Saharan Africa",
                      "Sub-Saharan Africa (excluding high income)",
                      "Sub-Saharan Africa (IDA & IBRD countries)",
                      "Upper middle income",
                      "World")

# Entferne Zeilen mit diesen Ländern aus dem DataFrame
employment_clean <- employment_filtered[!employment_filtered$`Country Name` %in% remove_countries, ]
agrar_gdp_clean <- agrar_gdp_filtered[!agrar_gdp_filtered$`Country Name` %in% remove_countries, ]
#NA entfernen
employment_clean <- employment_clean %>%
  filter(!`Country Name` %in% remove_countries & !is.na(`Country Name`))
agrar_gdp_clean <- agrar_gdp_clean %>%
  filter(!`Country Name` %in% remove_countries & !is.na(`Country Name`))
################################################################################
gdp_filtered <- gdp %>%  select(-c("Series Name", "Series Code" , "Country Code"))
colnames(gdp_filtered) <- str_replace(colnames(gdp_filtered), "\\[YR[0-9]{4}\\]", "")
# Entferne Zeilen mit diesen Ländern aus dem DataFrame
gdp_clean <- gdp_filtered[!gdp_filtered$`Country Name` %in% remove_countries, ]
#NA entfernen
gdp_clean <- gdp_clean %>%
  filter(!`Country Name` %in% remove_countries & !is.na(`Country Name`))
###############################################################################
# BIP pro Kopf ins Long-Format
gdp_long <- gdp_clean %>%
  pivot_longer(cols = -`Country Name`, names_to = "Year", values_to = "GDP_pc") %>%
  mutate(
    Year = as.integer(gsub("[^0-9]", "", Year)),  # Entfernt nicht-numerische Zeichen aus `Year`
    GDP_pc = na_if(GDP_pc, ".."),  # Setzt ".." auf NA
    GDP_pc = as.numeric(GDP_pc)  # Wandelt um in numeric
  )

# Agrarproduktion pro Kopf ins Long-Format
agrar_production_long <- agrar_gdp_clean %>%
  pivot_longer(cols = -`Country Name`, names_to = "Year", values_to = "Agrar_GDP_pc") %>%
  mutate(
    Year = as.integer(gsub("[^0-9]", "", Year)),  # Entfernt nicht-numerische Zeichen aus `Year`
    Agrar_GDP_pc = na_if(Agrar_GDP_pc, ".."),  # Setzt ".." auf NA
    Agrar_GDP_pc = as.numeric(Agrar_GDP_pc)  # Wandelt um in numeric
  )
# Employment ins Long-Format
employment_long <- employment_clean %>%
  pivot_longer(cols = -`Country Name`, names_to = "Year", values_to = "Employment") %>%
  mutate(
    Year = as.integer(gsub("[^0-9]", "", Year)),  # Entfernt nicht-numerische Zeichen aus `Year`
    Employment = na_if(Employment, ".."),  # Setzt ".." auf NA
    Employment = as.numeric(Employment)  # Wandelt um in numeric
  )
###############################################################################
# Merge Data 
merged_data <- right_join(gdp_long, agrar_production_long, by = c("Country Name", "Year"))
merged_data2 <- right_join(employment_long, merged_data, by = c("Country Name", "Year"))
merged_data2 <- merged_data2 %>%
  filter(!(is.na(GDP_pc) & is.na(Agrar_GDP_pc) & is.na(Employment)))
# Transform GDP 
merged_data2 <- merged_data2 %>%
  mutate(
    LN_GDP_pc = log(GDP_pc)
  )
# Filter Data 
merged_data2 <- merged_data2 %>% filter(Year >= 1989)

# Remove % 
merged_data2$diff <- merged_data2$Agrar_GDP_pc - merged_data2$Employment
merged_data2 <- merged_data2 %>%
  mutate(Employment = Employment / 100)
merged_data2 <- merged_data2 %>%
  mutate(Agrar_GDP_pc = Agrar_GDP_pc / 100)
merged_data2 <- merged_data2 %>%
  mutate(diff = diff / 100)
# Remove NA 
merged_data2 <- merged_data2 %>%
  filter(!is.na(Agrar_GDP_pc) & !is.na(Employment) & !is.na(diff) & !is.na(LN_GDP_pc))

#############################################################################
#Statischer Plot erstellen 
library(ggplot2)
library(plotly)
# Farbenblind Farben 
cb_palette <- c(
  "Agri. GDP Share" = "#0072B2",  # Blau
  "Agri. Employment Share" = "#E69F00",  # Orange
  "Agri. GDP Share - Employment" = "#009E73"  # Dunkelgrün
)

# Plot mit verstärkten Achsen & farbenfreundlicher Darstellung
ggplot(merged_data2, aes(x = LN_GDP_pc)) +
  geom_point(aes(y = Agrar_GDP_pc, color = "Agri. GDP Share"), shape = 16, size = 2) +  
  geom_point(aes(y = Employment, color = "Agri. Employment Share"), shape = 15, size = 2) +  
  geom_point(aes(y = diff, color = "Agri. GDP Share - Employment"), shape = 3, size = 2) +  
  scale_color_manual(values = cb_palette) +
  labs(
    title = "Structural Transformation: Agriculture and Economic Growth",
    x = "LN GDP per capita (Constant US$-2015)",
    y = "Share (%)",
    color = "Indicator"
  ) +
  theme_minimal(base_size = 14) +  
  theme(
    axis.text = element_text(size = 10, face = "bold"),  # Größer & fett für bessere Lesbarkeit
    axis.title = element_text(size = 10, face = "bold"),  # Größer & fett für mehr Deutlichkeit
    axis.line = element_line(size = 1.1, color = "grey"),  # Dickere Achsenlinien
    axis.ticks = element_line(size = 0.8, color = "grey"),  # Verstärkte Tick-Markierungen
    legend.text = element_text(size = 12),  
    legend.title = element_text(size = 14, face = "bold")  
  )

# Speichern 
ggsave("timmer_graph.png", width = 10, height = 6, dpi = 300)
###################################
#Dnyamischer Plot erstellen 
# Farbenblind-freundliche Farben 
cb_palette <- c(
  "Agri. GDP Share" = "#0072B2",  # Blau
  "Agri. Employment Share" = "#E69F00",  # Orange
  "Agri. GDP Share - Employment" = "#009E73"  # Dunkelgrün
)


x <- ggplot(merged_data2, aes(x = LN_GDP_pc)) +
  geom_point(aes(
    y = Agrar_GDP_pc, 
    color = "Agri. GDP Share",
    text = paste("Country:", `Country Name`, 
                 "<br>Year:", Year, 
                 "<br>Agrar GDP Share:", round(Agrar_GDP_pc, 2))
  ), shape = 16, size = 2) +
  
  geom_point(aes(
    y = Employment, 
    color = "Agri. Employment Share",
    text = paste("Country:", `Country Name`, 
                 "<br>Year:", Year, 
                 "<br>Employment:", round(Employment, 2))
  ), shape = 15, size = 2) +
  
  geom_point(aes(
    y = diff, 
    color = "Agri. GDP Share - Employment",
    text = paste("Country:", `Country Name`, 
                 "<br>Year:", Year, 
                 "<br>Difference:", round(diff, 2))
  ), shape = 3, size = 2) +
  
  scale_color_manual(values = cb_palette) +  
  
  coord_cartesian(ylim = c(-0.7, 1), xlim = c(5, 13)) +  # Achsenlimits
  
  labs(
    title = "Structural Transformation: Agriculture and Economic Growth",
    x = "LN GDP per capita (Constant US$-2015)",
    y = "Share (%)",
    color = "Indicator"
  ) +
  
  theme_minimal(base_size = 14) +  
  theme(
    axis.text = element_text(size = 14, face = "bold"),  
    axis.title = element_text(size = 16, face = "bold"),  
    axis.line = element_line(linewidth = 1.1, color = "grey"),  
    axis.ticks = element_line(linewidth = 1.2, color = "grey"), 
    legend.text = element_text(size = 12),  
    legend.title = element_text(size = 14, face = "bold")  
  )

# Interaktive plotly-Grafik mit vollständigen Tooltips
plotly_figure <- ggplotly(x, tooltip = "text")

# HTML speichern
htmlwidgets::saveWidget(plotly_figure, "timmer_graph.html")
