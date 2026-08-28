-- Roda das Competências · tabela de respostas
-- Colar UMA vez no SQL Editor do Supabase (projeto tqtkjmdkmtqgjcchonax).
-- Sem ela, o Enviar dos colegas não chega ao painel (fica só no aparelho).

create table if not exists public.roda_respostas (
  id bigint generated always as identity primary key,
  sessao text not null default 'geral' check (char_length(sessao) between 1 and 60),
  nome text not null check (char_length(nome) between 2 and 40),
  notas jsonb not null check (pg_column_size(notas) <= 8192),
  criado_em timestamptz not null default now()
);

alter table public.roda_respostas enable row level security;

-- a chave pública do site só INSERE (quem preenche) e LÊ (painel do apresentador);
-- sem policy de update/delete, ninguém altera ou apaga resposta pela chave pública
create policy roda_respostas_inserir on public.roda_respostas
  for insert to anon, authenticated
  with check (true);

create policy roda_respostas_ler on public.roda_respostas
  for select to anon, authenticated
  using (true);

-- o painel filtra por sessao e ordena/agrupa por criado_em (sorteio por dia)
create index if not exists roda_respostas_sessao_criado_idx
  on public.roda_respostas (sessao, criado_em);
