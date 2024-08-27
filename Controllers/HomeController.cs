using BIA.Models;
using BIA.Services;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;


namespace BIA.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly IServiceApi _service;
        public HomeController(ILogger<HomeController> logger, IServiceApi service)
        {
            _logger = logger;
            _service = service;
        }

        public IActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public async Task<IActionResult> List()
        {
            try
            {
                var data = await _service.GetAllAsync();
                return Json(data);
            }
            catch (Exception ex)
            {
                ViewBag.ErrorResult = ex?.InnerException?.Message;
                var errorResponse = new
                {
                    success = false,
                    message = ex?.InnerException?.Message,
                    errors = ex?.InnerException?.Message
                };
                return Json(errorResponse);
            }

        }
        [HttpPost]
        public async Task<JsonResult> Create(Tarefa tarefa)
        {
            try
            {

                await _service.PostTarefa(tarefa);
                var response = new
                {
                    success = true,
                    message = "Tarefa cadastrada com sucesso!"
                };

                return Json(response);

            }
            catch (Exception ex)
            {
                var errorResponse = new
                {
                    success = false,
                    message = ex?.InnerException?.Message,
                    errors = ex?.InnerException?.Message
                };
                return Json(errorResponse);
            }
        }

        [HttpPost]
        public async Task<JsonResult> Delete(Guid id)
        {
            try
            {
                await _service.DeleteTarefa(id);
                var response = new
                {
                    success = true,
                    message = "Tarefa excluída com sucesso!"
                };

                return Json(response);
            }
            catch (Exception ex)
            {
                var errorResponse = new
                {
                    success = false,
                    message = ex?.InnerException?.Message,
                    errors = ex?.InnerException?.Message
                };
                return Json(errorResponse);
            }
        }

        public IActionResult About()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
