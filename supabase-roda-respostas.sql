-- Roda das Competências (reb0w.github.io/roda-competencias): recria a tabela
-- das respostas, apagada em 14-10. Pedido do founder em 12-11, pra apresentação
-- do trabalho de 13-11. Pode colar mais de uma vez sem estragar nada.
-- Projeto Supabase: tqtkjmdkmtqgjcchonax (o mesmo do Quizinho).

create table if not exists public.roda_respostas (
  id bigint generated always as identity primary key,
  sessao text not null default 'geral' check (char_length(sessao) between 1 and 60),
  nome text not null check (char_length(nome) between 2 and 40),
  notas jsonb not null check (pg_column_size(notas) <= 8192),
  criado_em timestamptz not null default now()
);

alter table public.roda_respostas enable row level security;

-- A chave pública do site só INSERE (quem preenche) e LÊ (painel do
-- apresentador). Sem policy de update ou delete: ninguém altera nem apaga
-- resposta pela chave pública.
drop policy if exists roda_respostas_inserir on public.roda_respostas;
create policy roda_respostas_inserir on public.roda_respostas
  for insert to anon, authenticated
  with check (true);

drop policy if exists roda_respostas_ler on public.roda_respostas;
create policy roda_respostas_ler on public.roda_respostas
  for select to anon, authenticated
  using (true);

grant select, insert on public.roda_respostas to anon, authenticated;

-- O painel filtra pela rodada (sessao) e ordena pela hora.
create index if not exists roda_respostas_sessao_criado_idx
  on public.roda_respostas (sessao, criado_em);
