using BIA.Models;
using BIA.Services;
using Microsoft.AspNetCore.Mvc;

namespace BIA.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TarefasController : ControllerBase
    {
        private readonly IServiceApi _service;
        public TarefasController(IServiceApi service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            try
            {
                var data = await _service.GetAllAsync();
                return Ok(data);
            }
            catch
            {
                 throw;

            }
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] Tarefa tarefa)
        {
            try
            {

                await _service.PostTarefa(tarefa);
                return Created();

            }
            catch
            {
                throw;

            }
        }


        [HttpDelete]
        public async Task<IActionResult> Delete([FromBody] Tarefa tarefa)
        {
            try
            {
                await _service.DeleteTarefa(tarefa.Id);
                return Ok();
              
            }
            catch
            {
                throw;

            }
        }


        [HttpPost("alterarStatus")]
        public async Task<IActionResult> alterarStatus([FromBody] Tarefa tarefa)
        {
            try
            {
       
                await _service.AlternarImportante(tarefa.Id);
                return Ok();
             
            }
            catch
            {
                throw;

            }
        }
    }
}