const versaoController = require('../../../api/controllers/versao');

describe('Versao Controller', () => {
  let req, res;

  beforeEach(() => {
    // Setup fresh mocks para cada teste
    req = {};
    res = {
      send: jest.fn(),
    };
    
    // Limpar mocks e variáveis de ambiente
    jest.clearAllMocks();
    delete process.env.VERSAO_API;
  });

  describe('get method', () => {
    // ========================================
    // TESTES EXISTENTES (Revisados)
    // ========================================

    test('deve retornar a string de resposta correta', async () => {
      // Chama a função retornada pelo controller para obter o objeto controller
      const { get } = versaoController();
      // Chama o método get do objeto controller
      await get(req, res);

      expect(res.send).toHaveBeenCalledWith('Bia 4.2.0');
    });

    test('deve retornar a string de resposta correta quando VERSAO_API não está definido', async () => {
      // Simula o cenário onde VERSAO_API não está definido
      delete process.env.VERSAO_API;

      // Chama a função retornada pelo controller para obter o objeto controller
      const { get } = versaoController();
      // Chama o método get do objeto controller
      await get(req, res);

      expect(res.send).toHaveBeenCalledWith('Bia 4.2.0');
    });

    test('deve retornar a string de resposta correta quando VERSAO_API está definido', async () => {
      // Simula o cenário onde VERSAO_API está definido
      process.env.VERSAO_API = '1.0.0';

      // Chama a função retornada pelo controller para obter o objeto controller
      const { get } = versaoController();
      // Chama o método get do objeto controller
      await get(req, res);

      expect(res.send).toHaveBeenCalledWith('Bia 1.0.0');
    });

    // ========================================
    // NOVOS TESTES
    // ========================================

    test('deve retornar string no formato "Bia X.X.X"', async () => {
      // Verifica que a resposta segue o formato esperado com regex
      const { get } = versaoController();
      await get(req, res);
      
      expect(res.send).toHaveBeenCalled();
      const response = res.send.mock.calls[0][0];
      // Regex para validar formato: "Bia" seguido de espaço e versão numérica (X.X.X)
      expect(response).toMatch(/^Bia \d+\.\d+\.\d+$/);
    });

    test('deve ser uma função assíncrona', async () => {
      // Verifica que o método get retorna uma Promise
      const { get } = versaoController();
      const result = get(req, res);
      
      // Verifica que retorna uma Promise
      expect(result).toBeInstanceOf(Promise);
      await result;
    });

    test('deve usar versão padrão quando VERSAO_API é string vazia', async () => {
      // Testa comportamento com string vazia
      process.env.VERSAO_API = '';
      
      const { get } = versaoController();
      await get(req, res);
      
      // String vazia deve resultar na versão padrão devido ao operador ||
      expect(res.send).toHaveBeenCalledWith('Bia 4.2.0');
    });

    test('deve usar valor de VERSAO_API mesmo que seja inválido', async () => {
      // Testa que o controller não valida formato da versão
      process.env.VERSAO_API = 'versao-invalida';
      
      const { get } = versaoController();
      await get(req, res);
      
      // Controller aceita qualquer valor, mesmo que inválido
      expect(res.send).toHaveBeenCalledWith('Bia versao-invalida');
    });

    test('deve manter comportamento consistente em múltiplas chamadas', async () => {
      // Verifica que múltiplas chamadas produzem o mesmo resultado
      process.env.VERSAO_API = '5.0.0';
      const { get } = versaoController();
      
      // Primeira chamada
      await get(req, res);
      expect(res.send).toHaveBeenCalledWith('Bia 5.0.0');
      
      // Limpar mock
      res.send.mockClear();
      
      // Segunda chamada deve ter mesmo comportamento
      await get(req, res);
      expect(res.send).toHaveBeenCalledWith('Bia 5.0.0');
    });

    test('deve chamar res.send exatamente uma vez', async () => {
      // Verifica que não há chamadas duplicadas ou múltiplas
      const { get } = versaoController();
      await get(req, res);
      
      expect(res.send).toHaveBeenCalledTimes(1);
    });
  });
});