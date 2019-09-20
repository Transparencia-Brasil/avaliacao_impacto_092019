#Ids campanha enviados:

library(RPostgreSQL)
pg = dbDriver("PostgreSQL")

con = dbConnect(pg,
                user="read_only_user", password="xt83vJ2AZHvDv5kA",
                host ="142.93.186.109",
                port = 5432, dbname="ebdb")

inspections <- dbGetQuery(con, "SELECT * FROM inspections")

alertas_acao <- inspections %>%
  rename(inspection_id = id) %>%
  filter( user_id == 5977 |
            project_id %in% ids_acao & created_at > "2018-12-16" & comment != "NA",
          !(project_id == 31175 & user_id == 6866 ),
          !(project_id == 1006216 & user_id == 4564 ))

ids_acao <- as.character(alertas_acao$project_id)

setwd("C:/Users/coliv/Documents/avaliacao_impacto_092019/Bancos")
save(ids_acao, file="ids_acao.Rdata")
