# Questionario

1. Em qual camada foi implementado o mecanismo de cache? Explique por que essa decisão é adequada dentro da arquitetura proposta.

Repository, dentro do Data layer. Abstrai a origem dos dados das camadas superiores.

2. Por que o ViewModel não deve realizar chamadas HTTP diretamente?

lógica de apresentação e lógica de aquisição de dados devem ser separados. O ViewModel apenas prepara os dados para a interface do usuário.

3. O que poderia acontecer se a interface acessasse diretamente o DataSource?

A inteface fica acoplada a uma fonte de dados específica.

4. Como essa arquitetura facilitaria a substituição da API por um banco de dados local?

Nada da interface e viewmodel precisaria ser alterado, apenas datasource e repository.

## Gerenciamento de estado

O projeto usa apenas recursos nativos do Flutter, sem pacotes de terceiros
(Provider, Riverpod, BLoC), por ser um app de escopo enxuto. A escolha é
justificada da seguinte forma:

- **`setState` + classes de estado seladas** (`ProductsState`,
  `ProductDetailsState`): cada tela é dona do seu próprio estado de
  carregamento/sucesso/erro. O `switch` exaustivo sobre a `sealed class`
  garante, em tempo de compilação, que todos os estados (loading, erro e
  sucesso) sejam tratados na UI — cobrindo "tratamento de carregamento" e
  "tratamento de erro" de forma segura.
- **`ChangeNotifier` + `ListenableBuilder`** para estado compartilhado entre
  telas. O `FavoritesManager` (e o `SessionManager`) vivem acima das telas e
  são injetados por construtor. Como os favoritos precisam refletir
  automaticamente em mais de uma tela (lista, filtro e detalhes), um
  `ChangeNotifier` permite que qualquer `ListenableBuilder` observando o
  manager seja reconstruído ao chamar `notifyListeners()`, sem espalhar
  `setState` manual nem precisar recarregar dados ao voltar de uma tela.
  `ChangeNotifier`/`ListenableBuilder` fazem parte do próprio framework
  (`flutter/foundation`), mantendo a "atualização automática da interface"
  sem dependências externas.

Essa combinação mantém a separação **modelo / serviço / sessão / tela**:
`FavoritesManager` é estado de sessão local (em memória), exposto à camada de
apresentação e limpo no logout.