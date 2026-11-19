-- CCM520 - Internet das Coisas | Projeto 2 (o mesmo script da Aula 9)
-- Executado pelo MySQL apenas na PRIMEIRA inicialização (volume vazio).
--
-- Usuários do banco (princípio do menor privilégio):
--   root    / senha configurada em plataforma/.env     -> administração (só para você, no terminal)
--   cygnus  / senha configurada em plataforma/.env  -> ESCREVE o histórico no banco "fei" (criado pelo docker-compose)
--   grafana / senha personalizada neste script -> só LÊ o banco "fei" (fonte de dados do Grafana)

CREATE USER IF NOT EXISTS 'grafana'@'%' IDENTIFIED BY 'Jpmonti62026_ReadOnly_46b8';
GRANT SELECT ON `fei`.* TO 'grafana'@'%';
FLUSH PRIVILEGES;
