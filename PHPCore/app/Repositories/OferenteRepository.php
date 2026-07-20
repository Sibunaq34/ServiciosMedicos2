<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\WebService;
use App\Core\ServicioSoap;

final class OferenteRepository
{
    private ServicioSoap $soap;

    public function __construct()
   {
        $this->soap = new ServicioSoap(WebService::OFERENTES);
    }

    /**
     * @return array<int, array{id_oferente:int, identificacion:string, nombre_completo:string}>
     */
    public function listarPorPuesto(string $codigoPuesto): array
    {
        $respuesta = $this->soap->call('ListarOferentesPorPuesto', [
            'codigoPuesto' => $codigoPuesto,
        ]);

        return array_map(
            static fn(array $fila): array => [
                'id_oferente'     => (int) ($fila['IdOferente'] ?? 0),
                'identificacion'  => (string) ($fila['Identificacion'] ?? ''),
                'nombre_completo' => (string) ($fila['NombreCompleto'] ?? ''),
            ],
            $this->normalizar($respuesta)
        );
    }

    /**
     * @return array<int, array{id_requisito:int, nombre_requisito:string}>
     */
    public function listarRequisitos(string $codigoPuesto): array
    {
        $respuesta = $this->soap->call('ListarRequisitosPorPuesto', [
            'codigoPuesto' => $codigoPuesto,
        ]);

        return array_map(
            static fn(array $fila): array => [
                'id_requisito'     => (int) ($fila['IdRequisito'] ?? 0),
                'nombre_requisito' => (string) ($fila['NombreRequisito'] ?? ''),
            ],
            $this->normalizar($respuesta)
        );
    }


    private function normalizar(mixed $respuesta): array
    {
        if ($respuesta === null) {
            return [];
        }

        if (is_object($respuesta) && count(get_object_vars($respuesta)) === 1) {
            $respuesta = array_values(get_object_vars($respuesta))[0];
        }

        if (is_object($respuesta) && count(get_object_vars($respuesta)) === 0) {
            return [];
        }

        if (is_object($respuesta) && count(get_object_vars($respuesta)) === 1) {
            $respuesta = array_values(get_object_vars($respuesta))[0];
        }

        if ($respuesta === null) {
            return [];
        }

        if (!is_array($respuesta)) {
            $respuesta = [$respuesta];
        }

        return array_map(static fn($fila): array => (array) $fila, $respuesta);
    }
}
