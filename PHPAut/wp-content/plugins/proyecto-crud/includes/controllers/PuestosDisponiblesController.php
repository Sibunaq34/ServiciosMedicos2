<?php

require_once plugin_dir_path(__DIR__) . 'services/PuestosDisponiblesService.php';

class PuestosDisponiblesController
{
    private PuestosDisponiblesService $service;

    public function __construct(?PuestosDisponiblesService $service = null)
    {
        $this->service = $service ?: new PuestosDisponiblesService();
    }

    public function obtenerDatosListado(): array
    {
        $urlActual = home_url(add_query_arg(null, null));
        $urlAut3 = $this->service->obtenerUrlRegistroOferente();

        return array_map(function (array $puesto) use ($urlAut3, $urlActual): array {
            $codigo = (string) ($puesto['codigo_puesto'] ?? '');
            $nombre = (string) ($puesto['nombre_puesto'] ?? '');

            return [
                'nombre' => $nombre,
                'href' => $this->service->construirUrlAut3($urlAut3, $codigo, $nombre, $urlActual),
            ];
        }, $this->service->obtenerPuestosDisponibles());
    }
}
