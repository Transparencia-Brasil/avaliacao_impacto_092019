#Ajustes das planilhas para avaliação de impacto.

#Aqui estou só tirando as obras de quadras e mantendo todas as outras.

library(dplyr)
library(janitor)
library(data.table)

como_data <- function(x) {
  
  stopifnot(require(dplyr))
  x <- gsub(" .*", "", x)
  y <- gsub(".*/", "", x)
  x <- if_else((nchar(y)==4), as.Date(x, format="%d/%m/%Y"),
               as.Date(x, format="%d/%m/%y"))
  
}

setwd("C:/Users/coliv/Documents/tadepe-tdp_impact2/bancos")
load("controle1.Rdata")





#Critérios
projetos_escolas_e_creches <- c("Escola de Educação Infantil Tipo B",
                                "MI - Escola de Educação Infantil Tipo B",
                                "Projeto 2 Convencional",
                                "Projeto 1 Convencional",
                                "Escola de Educação Infantil Tipo C",
                                "Espaço Educativo - 12 Salas" ,
                                "Escola com Projeto elaborado pelo proponente",
                                "Espaço Educativo Ensino Médio Profissionalizante",
                                "Espaço Educativo - 02 Salas",
                                "Espaço Educativo - 06 Salas",
                                "Espaço Educativo - 04 Salas",
                                "Espaço Educativo - 01 Sala",
                                "Espaço Educativo - 08 Salas",
                                "Espaço Educativo - 10 Salas",
                                "Escola de Educação Infantil Tipo A",
                                "Escola com projeto elaborado pelo concedente",
                                "MI - Escola de Educação Infantil Tipo C",
                                "Projeto Tipo C - Bloco Estrutural",
                                "Projeto Tipo B - Bloco Estrutural")

projetos_visiveis_no_app <- c("Projeto 2 Convencional",
                              "Projeto 1 Convencional",
                              "Espaço Educativo - 12 Salas" ,
                              "Espaço Educativo - 02 Salas",
                              "Espaço Educativo - 06 Salas",
                              "Espaço Educativo - 04 Salas",
                              "Espaço Educativo - 01 Sala")

status_visiveis_app <- c("Inacabada",
                         "Planejamento pelo proponente",
                         "Execução",
                         "Paralisada",
                         "Licitação",
                         "Contratação",
                         "Em Reformulação")

files <- c("obras_08032018.csv", "obras_upload28092018.csv", 
           "obras2019_08_16.csv", "obras30052017.csv"  )

setwd("C:/Users/coliv/Documents/avaliacao_impacto_092019/Planilhas SIMEC")
for(i in 1:length(files)){
  
  a <- fread(files[i], encoding = "UTF-8")
  an <- gsub(".csv", "", files[i])
  
  assign(an, a)
  
}

#Começo do primeiro experimento

obras_inicio_projeto <- obras30052017 %>%
  clean_names() %>%
  filter(tipo_do_projeto %in% projetos_escolas_e_creches) %>%
  select(id, nome, situacao, municipio, uf, cep, logradouro, bairro, percentual_de_execucao,
         data_prevista_de_conclusao_da_obra, tipo_do_projeto, rede_de_ensino_publico, 
         nome_da_entidade) %>%
  mutate(visivel_no_app = ifelse(situacao %in% status_visiveis_app &
                                   tipo_do_projeto %in% projetos_visiveis_no_app, 1, 0)) %>%
  left_join(munic_controle, by = c("municipio" = "municipality" , "uf" = "state")) %>%
  mutate(grupo_controle = ifelse(is.na(grupo_controle) | visivel_no_app == 0, 0, grupo_controle),
         visivel_no_app = ifelse(grupo_controle == 1, 0, visivel_no_app),
         data_prevista_de_conclusao_da_obra = como_data(data_prevista_de_conclusao_da_obra)) 

setwd("C:/Users/coliv/Documents/avaliacao_impacto_092019/Situação das obras")
save(obras_inicio_projeto, file="obras_inicio_projeto.Rdata")

#Fim do primeiro experimento

obras_fim_primeira_fase <- obras_08032018 %>%
  clean_names() %>%
  filter(tipo_do_projeto %in% projetos_escolas_e_creches) %>%
  select(id, nome, situacao, municipio, uf, cep, logradouro, bairro, percentual_de_execucao,
         data_prevista_de_conclusao_da_obra, tipo_do_projeto, rede_de_ensino_publico, 
         nome_da_entidade) %>%
  mutate(visivel_no_app = ifelse(situacao %in% status_visiveis_app &
                                   tipo_do_projeto %in% projetos_visiveis_no_app, 1, 0)) %>%
  left_join(munic_controle, by = c("municipio" = "municipality" , "uf" = "state")) %>%
  mutate(grupo_controle = ifelse(is.na(grupo_controle) | visivel_no_app == 0, 0, grupo_controle),
         visivel_no_app = ifelse(grupo_controle == 1, 0, visivel_no_app),
         data_prevista_de_conclusao_da_obra = como_data(data_prevista_de_conclusao_da_obra)) 

save(obras_fim_primeira_fase, file="obras_fim_primeira_fase.Rdata")

#Começo do segundo experimento

#Primeiro eu preciso pegar as obras do grupo controle da segunda fase:
setwd("C:/Users/coliv/Documents/avaliacao_impacto_092019/Bancos")
load("ids_controle_seg_fase.Rdata")


#E os ids de controle da campanha que efetivamente foram enviados
setwd("C:/Users/coliv/Documents/avaliacao_impacto_092019/Bancos")
load("ids_acao.Rdata")


# Para estar visível no app, a obra precisava ser cumprir os critérios ou ser habilitada 
# manualmente. Como o registro das que foram habilitadas manualmente já mudou, fiz um arquivo
# com os ides visíveis no app a partir da outra avaliação de impacto.

setwd("C:/Users/coliv/Documents/avaliacao_impacto_092019/Bancos")
load("ids_visible_fase_dois.Rdata")
ids_visible_fase_dois <- ids_visible_fase_dois$id

obras_antes_inicio_seg_fase <- obras_upload28092018 %>%
  clean_names() %>%
  filter(tipo_do_projeto %in% projetos_escolas_e_creches) %>%
  select(id, nome, situacao, municipio, uf, cep, logradouro, bairro, percentual_de_execucao,
         data_prevista_de_conclusao_da_obra, tipo_do_projeto, rede_de_ensino_publico, 
         nome_da_entidade) %>%
  mutate(id = as.character(id),
         visivel_no_app_seg_fase = ifelse(id %in% ids_visible_fase_dois, 1, 0),
         grupo_controle_app = ifelse(id %in% id_controle_app_final, 1, 0),
         campanha_tdp = ifelse(id %in% ids_acao, 1, 0),
         grupo_controle_campanha = ifelse(id %in% id_controle_campanha_final, 1, 0),
         data_prevista_de_conclusao_da_obra = como_data(data_prevista_de_conclusao_da_obra))

setwd("C:/Users/coliv/Documents/avaliacao_impacto_092019/Situação das obras")
save(obras_antes_inicio_seg_fase, file="obras_antes_inicio_seg_fase.Rdata")


#Agora para o fim da segunda fase:

obras_fim_seg_fase <- obras2019_08_16 %>%
  clean_names() %>%
  filter(tipo_do_projeto %in% projetos_escolas_e_creches) %>%
  select(id, nome, situacao, municipio, uf, cep, logradouro, bairro, percentual_de_execucao,
         data_prevista_de_conclusao_da_obra, tipo_do_projeto, rede_de_ensino_publico, 
         nome_da_entidade) %>%
  mutate(id = as.character(id),
         visivel_no_app_seg_fase = ifelse(id %in% ids_visible_fase_dois, 1, 0),
         grupo_controle_app = ifelse(id %in% id_controle_app_final, 1, 0),
         campanha_tdp = ifelse(id %in% ids_acao, 1, 0),
         grupo_controle_campanha = ifelse(id %in% id_controle_campanha_final, 1, 0),
         data_prevista_de_conclusao_da_obra = como_data(data_prevista_de_conclusao_da_obra))

setwd("C:/Users/coliv/Documents/avaliacao_impacto_092019/Situação das obras")
save(obras_fim_seg_fase, file="obras_antes_inicio_seg_fase.Rdata")
