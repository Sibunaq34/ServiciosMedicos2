<?php

require_once plugin_dir_path(__DIR__) . 'repository/PuestosDisponiblesRepository.php';

class PuestosDisponiblesService
{
    private PuestosDisponiblesRepository $repository;

    public function __construct(?PuestosDisponiblesRepository $repository = null)
    {
        $this->repository = $repository ?: new PuestosDisponiblesRepository();
    }

    public function obtenerPuestosDisponibles(): array
    {
        return $this->repository->obtenerActivos();
    }

    public function obtenerUrlRegistroOferente(): string
    {
        // La URL de Aut3 se resuelve en tiempo de ejecucion buscando por slug
        // en vez de fijar el post ID para no depender del ID interno.
        $pagina = get_page_by_path('registro-de-oferente', OBJECT, 'page');

        if ($pagina instanceof WP_Post) {
            $permalink = get_permalink($pagina);

            if ($permalink) {
                return $permalink;
            }
        }

        return home_url('/');
    }

    public function construirUrlAut3(string $urlAut3, string $codigoPuesto, string $nombrePuesto, string $urlRetorno): string
    {
        $query = [
            'codigo_puesto' => rawurlencode($codigoPuesto),
            'nombre_puesto' => rawurlencode($nombrePuesto),
            'url_retorno'   => rawurlencode($urlRetorno),
        ];

        return esc_url(add_query_arg($query, $urlAut3));
    }
}
