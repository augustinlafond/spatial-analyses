mean_ipsl_gfdl_models <- function(path_1, path_2) {
  
  ### load gfdl model output ##############
  load(path_1)
  
  r_gfdl <- rast(nrows = 180, ncols = 360,
                 xmin = 0, xmax = 360,
                 ymin = -90, ymax = 90,
                 vals = scena_year[,171])
  
  # Assign coordinate reference system (WGS84)
  crs(r_gfdl) <- "EPSG:4326"
  
  # Inverser selon Y (latitude)
  r_gfdl <- flip(r_gfdl, direction = "vertical")  
  
  ### load IPSL model output ##############
  load(path_2)
  
  r_ipsl <- rast(nrows = 180, ncols = 360,
                 xmin = 0, xmax = 360,
                 ymin = -90, ymax = 90,
                 vals = scena_year[,172])
  
  # Assign coordinate reference system (WGS84)
  crs(r_ipsl) <- "EPSG:4326"
  
  # Inverser selon Y (latitude)
  r_ipsl <- flip(r_ipsl, direction = "vertical")  
  
  
  ###### calculate mean between the two models ###########
  # Empiler les rasters
  r_mean_ipsl_gfdl <- c(r_ipsl, r_gfdl)
  
  # Calculer la moyenne pixel par pixel
  r_mean_ipsl_gfdl <- app(r_mean_ipsl_gfdl, mean, na.rm = TRUE)
  
  # Convert raster to points
  mean_ipsl_gfdl_sf <- as.data.frame(r_mean_ipsl_gfdl, xy = TRUE, na.rm = TRUE) %>%
    rename(lon = x, 
           lat = y,
           t_mean = mean) %>%
    mutate(lon = ifelse(lon > 180, lon - 360, lon))
  
  # Convert to sf object
  mean_ipsl_gfdl_sf <- st_as_sf(mean_ipsl_gfdl_sf, coords = c("lon", "lat"), crs = 4326)
  
  sf_use_s2(FALSE)
  
  # on créé une grille sf à la même résolution que les données du modele ocim
  bbox <- st_bbox(c(xmin = -180, xmax = 180, ymin = -90, ymax = 90), crs = 4326)
  grid_fseq <- st_as_sf(st_make_grid(st_as_sfc(bbox), cellsize = c(1, 1), what = "polygons")) 
  
  mean_ipsl_gfdl_sf <- grid_fseq %>%
    st_join(mean_ipsl_gfdl_sf)
  
  return(mean_ipsl_gfdl_sf)
  
  rm(bbox, grid_fseq, r_mean_ipsl_gfdl, r_ipsl, r_gfdl)
}