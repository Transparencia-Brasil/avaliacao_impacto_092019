library(dplyr)

setwd("C:/Users/coliv/Documents/tadepe-tdp_impact2/bancos")
load("obras_antes_inicio_seg_fase")

impact_antiga_obras_seg_fase <- obras_antes_inicio_seg_fase
rm(obras_antes_inicio_seg_fase)

ids_visible_fase_dois <- impact_antiga_obras_seg_fase %>%
  filter(visivel_no_app_seg_fase == 1) %>%
  select(id)

setwd("C:/Users/coliv/Documents/avaliacao_impacto_092019/Planilhas SIMEC")
save(ids_visible_fase_dois, file="ids_visible_fase_dois.Rdata")
