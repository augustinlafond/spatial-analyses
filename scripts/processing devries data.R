library(ncdf4)
library(terra)

# Ouvrir le fichier NetCDF
nc_file <- nc_open("data/fseq_OCIM2_48L.nc")

# Extraire les variables
fseq <- ncvar_get(nc_file, "fseq")  # Fraction de carbone (ocean_grid_point, time)
lat <- ncvar_get(nc_file, "LAT")  # Latitude (3D)
lon <- ncvar_get(nc_file, "LON")  # Longitude (3D)
depth <- ncvar_get(nc_file, "DEPTH")  # Profondeur (3D)
mask <- ncvar_get(nc_file, "MASK")
vol <- ncvar_get(nc_file, "VOL") 
area <- ncvar_get(nc_file, "AREA")
                  
# Fermer le fichier
nc_close(nc_file)

# Initialiser un tableau 3D vide
FSEQ_100yr <- array(NA, dim(mask))  # Même dimensions que MASK

# Trouver l'index correspondant à 100 ans
# Remplir FSEQ_100yr avec les valeurs de fseq là où MASK == 1 (océan)
FSEQ_100yr[mask == 1] <- fseq[, 100]

# Trouver le nombre de cellules océaniques en profondeur pour chaque point (somme de MASK sur Z)
TOPO <- apply(mask, c(1,2), sum)


# Initialiser une matrice 2D pour les valeurs au fond marin
fseq_bottom_100yr <- matrix(NA, nrow = dim(mask)[1], ncol = dim(mask)[2])

# Remplir avec les valeurs de séquestration à la couche la plus profonde de chaque colonne d'eau
for (i in 1:dim(mask)[1]) {
  for (j in 1:dim(mask)[2]) {
    if (TOPO[i, j] != 0) {  # Si au moins une couche océanique existe
      fseq_bottom_100yr[i, j] <- FSEQ_100yr[i, j, TOPO[i, j]]
    }
  }
}

# Carte de la fraction de CO₂ séquestrée au fond (derniere valeur de chaque pixel) après 100 ans, focus sur l'Europe
df_fseq <- data.frame(
  longitude = as.vector(lon[,,1]),
  latitude = as.vector(lat[,,1]),
  fseq_value = as.vector(fseq_bottom_100yr)
)

ggplot() +
  geom_tile(data = df_fseq %>%
              mutate(longitude = ifelse(longitude > 180, longitude - 360, longitude)) %>%
              filter(longitude >= -20 & longitude <= 15,
                     latitude >= 30 & latitude <= 65), aes(x = longitude, y = latitude, fill = fseq_value), alpha = 0.8) +
  geom_sf(data = ne_countries(scale = "medium", returnclass = "sf"), fill = NA, color = "black", size = 0.3) + 
  scale_fill_viridis_c(option = "magma", na.value = "gray") +
  coord_sf (xlim = c(-20,15), ylim = c(30, 65)) +
  theme_minimal() +
  labs(title = "Fraction de CO₂ restant séquestré après 100 ans",
       fill = "Fraction séquestrée")

### TO DO ###
# Pour la suite on continue de travailler avec FSEQ_100yr qui est un tableau a 3D (lat x lon x prof) qui contient les fractions 
# de CO2 restant séquestré après 100 ans. 

# Objectif : avoir pour chaque pixel OCIM la valeur de fseq à la profondeur la plus proche de la profondeur moyenne calculée à partir des données bathymétriques

# La méthodologie consiste en :

# 1) initialiser une matrice 2D remplie de NaN qui contiendra les valeurs de fseq qui nous interessent. 
# 2) superposer la grille bathymétrique avec la grille OCIM afin de calculer la profondeur moyenne associée à chaque pixel de la grille OCIM. 
# 3) Cela permettra d'obtenir une matrice 2D (lat x lon) avec les profondeurs les plus proches du modele OCIM (necessitera certainement une boucle pour trouver pour chaque pixel i x j la profondeur OCIM la plus proche de la profondeur moyenne issue des données bathy) 
# 4) Une fois cette matrice 2D des profondeurs, il n'y aura plus qu'à aller extraire les données dans FSEQ_100yr et à remplir la matrice 2D initialisée au début



####################################################################


# Ouvrir le fichier fseq
nc_fseq <- nc_open("data/fseq_OCIM2_48L.nc")

# Charger la grille de fseq
mask <- ncvar_get(nc_fseq, "MASK")   # (91,180,48) Terre/Mer
lat_fseq <- ncvar_get(nc_fseq, "LAT") # (91,180,48) Latitude
lon_fseq <- ncvar_get(nc_fseq, "LON") # (91,180,48) Longitude

# Fermer le fichier fseq
nc_close(nc_fseq)

# we extract bathymetric data from the netCDF file
nc_bathy <- nc_open("data/terrain_characteristics_6d78_4f59_9e1f_U1739441840737.nc")

# Charger la bathymétrie
bathy <- ncvar_get(nc_bathy, "bathymetry_mean") # (7200, 3600)
lat_bathy <- ncvar_get(nc_bathy, "latitude")    # (3600)
lon_bathy <- ncvar_get(nc_bathy, "longitude")   # (7200)

# Fermer le fichier bathymétrie
nc_close(nc_bathy)

# Inverser les colonnes (latitude) de la matrice bathymétrique pour avoir le nord au nord et le sud au sud
bathy <- bathy[, ncol(bathy):1]  # Inverse les lignes

# Créer un raster de la bathymétrie
r_bathy <- rast(nrows = length(lat_bathy), ncols = length(lon_bathy),
                xmin = -180, xmax = 180,
                ymin = -90, ymax = 90,
                vals = as.vector(bathy))

# Définir la projection
crs(r_bathy) <- "EPSG:4326"

# Afficher un aperçu
plot(r_bathy, main = "Bathymétrie (résolution 0.05°)")

# Créer un raster correspondant à la grille fseq
r_fseq <- rast(nrows = dim(mask)[1], ncols = dim(mask)[2],
               xmin = -180, xmax = 180,
               ymin = -90, ymax = 90)

crs(r_fseq) <- "EPSG:4326"

# Compute resolution of both grids
res_bathy <- res(r_bathy)  # Resolution of bathymetry raster
res_fseq <- res(r_fseq)    # Resolution of fseq raster

# Compute the aggregation factor dynamically
fact_x <- res_fseq[1] / res_bathy[1]
fact_y <- res_fseq[2] / res_bathy[2]

# Ré-échantillonner la bathymétrie à la résolution de fseq (moyenne par pixel)
r_bathy_resampled <- aggregate(r_bathy, fact = c(fact_x, fact_y), fun = mean, na.rm = TRUE)


# Afficher le raster ré-échantillonné
plot(r_bathy_resampled, main = "Bathymétrie ré-échantillonnée à la résolution de fseq")

# Create a matrix of fseq grid cell centers
fseq_coords <- cbind(as.vector(lon_fseq[,,1]), as.vector(lat_fseq[,,1]))

# Convert fseq longitudes from [0,360] to [-180,180]
fseq_coords[,1] <- ifelse(fseq_coords[,1] > 180, fseq_coords[,1] - 360, fseq_coords[,1])

# Convert to spatial points
fseq_points <- vect(fseq_coords, crs = crs(r_fseq))

# Extract bathymetry values at these points
bathy_fseq <- extract(r_bathy_resampled, fseq_points, method = "simple")


# Create a dataframe for visualization
grid_df <- data.frame(
  latitude = fseq_coords[,2],
  longitude = fseq_coords[,1],
  bathymetry = bathy_fseq[,2]
)


# on vérifie à quoi ressemble les valeurs moyennes de bathymetrie par pixel selon la grille de fseq
bbox <- st_bbox(c(xmin = -180, xmax = 180, ymin = -90, ymax = 90), crs = 4326)
grid <- st_as_sf(st_make_grid(st_as_sfc(bbox), cellsize = c(2, 1.978022), what = "polygons")) 

test <- grid %>%
  st_join(grid_df %>%
            st_as_sf(coords = c("longitude", "latitude"), crs = 4326))

mapview(test)

rm(test)

# On cherche pour chaque pixel de FSEQ_100yr, la profondeur la plus proche dans le modèle de DeVries de la profondeur moyenne calculée à partir des données bathymétriques. 
# On extrait la valeur correspondant fseq que l'on store dans une matrice 2D (lat x lon)

# on initialise grid_df avec une nouvelle colonne fseq remplie de NaN
grid_df <- grid_df %>%
  mutate(fseq = NA)

lat_unique <- grid_df %>% distinct(latitude) %>% pull( latitude)
lon_unique <- grid_df %>% distinct(longitude) %>% pull(longitude)

# Remplir avec les valeurs de séquestration à la couche la plus profonde de chaque colonne d'eau
for (i in length(lat_unique)) {
  for (j in 1:length(lon_unique)) {
    
    idx <- which(grid_df$latitude == lat_unique[i] & grid_df$longitude == lon_unique[j])
    fseq_i_j <- data.frame(depth_ocim = depth[1,1,],
                           fseq = FSEQ_100yr[i,j,],
                           mean_depth = -grid_df$bathymetry[idx]) %>%
      filter(!is.na(fseq)) %>%
      mutate(diff = mean_depth - depth_ocim)
    
    grid_df[idx, 4] <- fseq_i_j
    
    }
  }



