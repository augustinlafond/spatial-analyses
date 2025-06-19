# Examples of spatial analyses carried out for the BLOOM association

This directory contains a non-exhaustive list of mini-projects involving spatial data analysis carried out for the BLOOM association.
R packages commonly used for this type of analysis: sf and terra.
Data formats processed: raster, netCDF.

Below is a brief description of each project:

# Project 1: Estimation of the carbon contained in fish that is not sequestered by the ocean due to fishing. 
As part of a carbon assessment of French fisheries carried out by the BLOOM association in conjunction with the Shift Project, I estimated the carbon contained in fish that was not sequestered 
by the ocean via the biological pump due to fishing. This type of approach, which consists of integrating the alteration of the biological carbon pump into the carbon footprint of fish caught, 
is recent and is based, among other things, on the work of researchers at the Marbec laboratory in Montpellier ([ref 1](https://www.science.org/doi/full/10.1126/sciadv.abb4848), 
[ref 2](https://theses.fr/2023UMONG120), [ref 3](https://www.nature.com/articles/s41467-024-52135-6)).

We hypothesize that carbon from fish that escapes surface predation sinks to the ocean floor. Some of this carbon is remineralized during the fall of the carcasses in the water column by bacterial activity. 
The sequestration time of carbon that reaches the ocean floor also depends on depth and ocean circulation. In general, the deeper the carbon is injected, the longer it will be sequestered.
 
## Data used
- French fishery catch data come from the STECF database. These data are aggregated by FAO sub-areas. This explains why we have estimated for each of these areas i) a remineralization factor 
for the carbon contained in carcasses that sink to the ocean floor (depending on depth and temperature) and ii) the proportion of carbon trapped for at least 100 years in the ocean 
(i.e., the minimum threshold at which carbon is considered to be sequestered by the ocean). At the end of the analysis, these two factors are applied to the landing data to estimate the proportion 
of carbon from these fish that would have been sequestered at the bottom of the ocean in the absence of fishing. 
- Output from the [Ocean Circulation Inverse Model (OCIM)](https://figshare.com/articles/dataset/AIBECS-OCIM0_1/8317085/3?file=18789281). To estimate the fraction of carbon sequestered for 
at least 100 years for each FAO zone.
 - Global ocean bathymetry data (https://bio-oracle.org/downloads-to-email.php). To estimate the average depth of each FAO sub-area. This is essential for applying the carcass remineralization model, 
 which depends on depth.  
- Output from the Institut Pierre Simon Laplace (IPSL) and the Geophysical Fluid Dynamics Laboratory (GFDL) models to obtain temperature maps for each layer depth of the ocean. This is essential 
for applying the carcass remineralization model, which also depends on the temperature of the ocean water layers.
- FAO shapefiles

# Project 2 : Analysis of fishing effort in the Basque Country as part of a proposal to create a marine protected area
This project aims to analyze in detail fishing effort in the Basque Country, on both the French and Spanish sides, in order to estimate the impact that the creation of a marine protected area covering 
the zone could have on fishermen. A proposal for the delimitation of the MPA is made.
Fishing effort is estimated in the potential implementation zone by type of vessel (gear x size). This type of analysis has shown, for example, that it is mainly on the Spanish side that the 
establishment of the MPA is likely to cause tensions among fishermen, with gillnetters (0-12 m) and purse seiners (12-24 and 24-40 m) occupying the 0-6 nm band, and bottom trawlers (24-40 m) 
occupying the 6-12 nm band. On the French side, activity is lower, which would allow for greater acceptance of the creation of a new MPA. A comparison of GFW data with data from the 
European Fleet Register also reveals that the vast majority of vessels under 15 meters are not represented in the GFW data; as vessels under 15 meters are not required by regulation to have 
an AIS transponder (EU Regulation 1224/2009). The GFW data is therefore partly biased by the under-representation of these coastal vessels, which make up the bulk of the Basque Country's fleet.

## Data used : 
- Marine protected areas shapefiles were downloaded from the [World Database on Protected Areas (WDPA)](https://www.protectedplanet.net/en/thematic-areas/wdpa?tab=WDPA)
- [Global Fishing Watch raster data](https://globalfishingwatch.org)
- [European fleet register](https://webgate.ec.europa.eu/fleet-europa/search_en)

# Project 3 : Comparison of fishing effort by European tuna seiners estimated by Global Fishing Watch and reported by regional fisheries management organizations (ICCAT and IOTC)

This analysis aimed to estimate the extent to which GFW data underestimates the fishing effort of tropical tuna vessels. This is partly due to the fact that these vessels frequently 
switch off their AIS transponders.

## Data used
- [Global Fishing Watch](https://globalfishingwatch.org) fishing event data
- Spatial catch data from the RFMOs ([IOTC](https://iotc.org/data/datasets), [ICCAT](https://www.iccat.int/en/accesingdb.HTML)

# Project 4 : Highligthing some issues with Global Fishing Watch data
This analysis aims to highlight significant differences between the fishing event data and GFW raster data that we are unable to explain. We also highlight very significant differences 
between the apparent fishing effort estimated by versions V2 and V3 of the API.

## Data used :
- GFW fishing events and raster data (V2 and V3 API)
- list of French beneficiaries of the Brexit dismantling plan
