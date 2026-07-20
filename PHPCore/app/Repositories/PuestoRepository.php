<?php
declare(strict_types=1);
namespace App\Repositories;

use App\Config\WebService;
use App\Core\SoapService;
use RuntimeException;

final class PuestoRepository
{
    public function listarActivos(): array
    {
        $configuracion = $this->configuracion();
        if ($configuracion === null) {
            throw new RuntimeException('CORE1_NO_DISPONIBLE');
        }
        [$wsdl, $operacion] = $configuracion;
        $respuesta = (new SoapService($wsdl))->call($operacion);
        $elementos = $this->lista($respuesta);
        $puestos = [];

        foreach ($elementos as $elemento) {
            $codigo = (string) $this->valor($elemento, ['CodigoPuesto', 'codigoPuesto', 'codigo_puesto', 'Codigo', 'codigo']);
            $nombre = (string) $this->valor($elemento, ['NombrePuesto', 'nombrePuesto', 'nombre_puesto', 'Nombre', 'nombre']);
            if ($codigo !== '' && $nombre !== '') {
                $puestos[] = ['codigoPuesto' => $codigo, 'nombrePuesto' => $nombre];
            }
        }
        return $puestos;
    }
private function configuracion(): ?array
{
    $wsdl = defined(WebService::class . '::PUESTOS_WSDL')
        ? constant(WebService::class . '::PUESTOS_WSDL')
        : (
            defined(WebService::class . '::PUESTOS')
                ? constant(WebService::class . '::PUESTOS')
                : null
        );

    if (!is_string($wsdl) || $wsdl === '') {
        return null;
    }

    return [$wsdl, 'ListarPuestosActivos'];
}

    private function lista(mixed $respuesta): array
    {
        while (is_object($respuesta) && count(get_object_vars($respuesta)) === 1) {
            $propiedades = get_object_vars($respuesta);
            $respuesta = reset($propiedades);
        }
        while (is_array($respuesta) && count($respuesta) === 1 && !array_is_list($respuesta)) {
            $respuesta = reset($respuesta);
        }
        if (is_object($respuesta)) {
            return [$respuesta];
        }
        return is_array($respuesta) ? (array_is_list($respuesta) ? $respuesta : [$respuesta]) : [];
    }

    private function valor(mixed $origen, array $nombres): mixed
    {
        foreach ($nombres as $nombre) {
            if (is_object($origen) && property_exists($origen, $nombre)) {
                return $origen->{$nombre};
            }
            if (is_array($origen) && array_key_exists($nombre, $origen)) {
                return $origen[$nombre];
            }
        }
        return '';
    }
}
