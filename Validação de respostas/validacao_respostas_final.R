#Valid answers

library(googledrive)
library(tidyr)
library(dplyr)
library(googlesheets)
library(RPostgreSQL)
library(data.table)
library(xlsx)

drive_find(n_max=10)
gs_ls() 

# Baixando df com a verificação se as respostas são válidas ou não.
respostas_validadas_sheet <- gs_title("Respostas_bianca")
respostas_validadas <- gs_read(respostas_validadas_sheet)

#Lembrando que é o ID DA RESPOSTA

verificadas <- as.character(respostas_validadas$id)

#Conectando com a aplicação
pg = dbDriver("PostgreSQL")

con = dbConnect(pg,
                user="read_only_user", password="xt83vJ2AZHvDv5kA",
                host ="142.93.186.109",
                port = 5432, dbname="ebdb")

# Bancos (auto-explicativos)

respostas = dbGetQuery(con, "SELECT * FROM answers")
messages <- dbGetQuery(con, "SELECT * FROM messages")
inspections <- dbGetQuery(con, "SELECT * FROM inspections")
projetos = dbGetQuery(con, "SELECT * FROM projects")
location_cities = dbGetQuery(con, "SELECT * FROM location_cities")
location_states = dbGetQuery(con, "SELECT * FROM location_states")

# Resolvendo aqui o encoding do nome das cidades, para não precisar resolver depois:
Encoding(respostas$content) <- "UTF-8"

novas_respostas <- respostas %>%
  mutate_all(as.character()) %>%
  filter(!id %in% verificadas)

#Verificando qual é o id do usuário que mandou a campanha de coordenadas:

inspections %>%
  group_by(user_id) %>%
  summarise(total = n()) %>%
  arrange(desc(total)) # usuário é 7374


setwd("C:/Users/coliv/Documents/avaliacao_impacto_092019/Validação de respostas")


write.xlsx(as.data.frame(novas_respostas), 
           file="novas_respostas.xlsx", sheetName="objeto",
           col.names=TRUE, row.names=FALSE, append=FALSE, showNA=FALSE)



## Novo arquivo de respostas validadas:

#Baixando o arquivo de novas respostas verificado:

novas_respostas_sheet <- gs_title("Novas respostas")
novas_respostas <- gs_read(novas_respostas_sheet)

novas_respostas <- novas_respostas %>%
  distinct(id, .keep_all = TRUE) %>%
  select(id, resposta_valida)

validacao_respostas_final <- respostas_validadas %>%
  select(id, resposta_valida) %>%
  bind_rows(novas_respostas) %>%
  distinct(id, .keep_all = TRUE)

setwd("C:/Users/coliv/Documents/avaliacao_impacto_092019/Validação de respostas")  
save(validacao_respostas_final, file="validacao_respostas_final.Rdata")  
