mean_temp_fao_zones <- function(df) {
  result <- st_intersection(df %>%
                    filter(!is.na(t_mean)) %>%
                    mutate(id = 1: n()) %>%
                    mutate(area_pixel = as.numeric(st_area(.))), fao_shp) %>%
    mutate(area_intersection = as.numeric(st_area(.))) %>%
    mutate(coverage_ratio = area_intersection/area_pixel) %>%
    mutate(t_weighted = t_mean * coverage_ratio) %>%
    with_groups(c("f_level", "f_code"), summarise, t_zone = sum(t_weighted, na.rm = T)/sum(coverage_ratio, na.rm = T)) %>%
    st_drop_geometry () 
  
  return(result)
  
}