const versaoController = require('../../../api/controllers/versao');

describe('Versao Controller', () => {
  // Mock para simular o objeto req e res
  const req = {};
  const res = {
    send: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('get deve retornar a string de resposta correta', () => {
    // Chama a função retornada pelo controller para obter o objeto controller
    const { get } = versaoController();
    // Chama o método get do objeto controller
    get(req, res);

    expect(res.send).toHaveBeenCalledWith('Bia 3.2.0');
  });

  test('get deve retornar a string de resposta correta quando VERSAO_API não está definido', () => {
    // Simula o cenário onde VERSAO_API não está definido
    delete process.env.VERSAO_API;

    // Chama a função retornada pelo controller para obter o objeto controller
    const { get } = versaoController();
    // Chama o método get do objeto controller
    get(req, res);

    expect(res.send).toHaveBeenCalledWith('Bia 3.2.0');
  });

  test('get deve retornar a string de resposta correta quando VERSAO_API está definido', () => {
    // Simula o cenário onde VERSAO_API está definido
    process.env.VERSAO_API = '1.0.0';

    // Chama a função retornada pelo controller para obter o objeto controller
    const { get } = versaoController();
    // Chama o método get do objeto controller
    get(req, res);

    expect(res.send).toHaveBeenCalledWith('Bia 1.0.0');
  });
});