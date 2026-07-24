<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\WebService;
use App\Core\ServicioSoap;
use RuntimeException;
use Throwable;

final class OferenteRepository
{
    private ?ServicioSoap $soap = null;

    /**
     * @return array<int, array{id_oferente:int, identificacion:string, nombre_completo:string}>
     */
    public function listarPorPuesto(string $codigoPuesto): array
    {
        try {
            $respuesta = $this->servicio()->call('ListarOferentesPorPuesto', [
                'codigoPuesto' => $codigoPuesto,
            ]);
        } catch (Throwable $exception) {
            throw new RuntimeException(
                "No fue posible consultar los oferentes para el puesto {$codigoPuesto}.",
                0,
                $exception
            );
        }

        return array_map(
            fn (mixed $fila): array => [
                'id_oferente' => (int) $this->valor($fila, ['IdOferente', 'idOferente', 'id_oferente'], 0),
                'nombre_completo' => (string) $this->valor($fila, ['NombreCompleto', 'nombreCompleto', 'nombre_completo'], ''),
                'identificacion' => (string) $this->valor($fila, ['Identificacion', 'identificacion'], ''),
            ],
            $this->normalizarOferentes($respuesta)
        );
    }

    /**
     * @return array<int, array{id_requisito:int, nombre_requisito:string}>
     */
    public function listarRequisitos(string $codigoPuesto): array
    {
        $respuesta = $this->servicio()->call('ListarRequisitosPorPuesto', [
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


    private function servicio(): ServicioSoap
    {
        return $this->soap ??= new ServicioSoap(WebService::OFERENTES);
    }

    private function normalizarOferentes(mixed $respuesta): array
    {
        $respuesta = $this->extraer($respuesta, 'ListarOferentesPorPuestoResult');
        $respuesta = $this->extraer($respuesta, 'OferenteCumplimientoDto');

        if ($respuesta === null || $respuesta === [] || (is_object($respuesta) && get_object_vars($respuesta) === [])) {
            return [];
        }

        if (is_object($respuesta)) {
            $respuesta = get_object_vars($respuesta);
        }

        if (!is_array($respuesta)) {
            $respuesta = [$respuesta];
        }

        if (!array_is_list($respuesta)) {
            $respuesta = [$respuesta];
        }

        return array_values($respuesta);
    }

    private function normalizar(mixed $respuesta): array
    {
        if ($respuesta === null) {
            return [];
        }

        while (is_object($respuesta) && count(get_object_vars($respuesta)) === 1) {
            $propiedades = get_object_vars($respuesta);
            $respuesta = reset($propiedades);
        }

        if ($respuesta === null) {
            return [];
        }
        if (!is_array($respuesta)) {
            $respuesta = [$respuesta];
        }

        return array_map(static fn (mixed $fila): array => (array) $fila, $respuesta);
    }

    private function extraer(mixed $respuesta, string $propiedad): mixed
    {
        if (is_object($respuesta) && property_exists($respuesta, $propiedad)) {
            return $respuesta->{$propiedad};
        }
        if (is_array($respuesta) && array_key_exists($propiedad, $respuesta)) {
            return $respuesta[$propiedad];
        }

        return $respuesta;
    }

    private function valor(mixed $origen, array $nombres, mixed $predeterminado): mixed
    {
        foreach ($nombres as $nombre) {
            if (is_object($origen) && property_exists($origen, $nombre)) {
                return $origen->{$nombre};
            }
            if (is_array($origen) && array_key_exists($nombre, $origen)) {
                return $origen[$nombre];
            }
        }

        return $predeterminado;
    }
}
