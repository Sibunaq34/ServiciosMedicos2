<?php
declare(strict_types=1);
namespace App\Repositories;

use App\Config\WebService;
use App\Core\SoapService;
use RuntimeException;
use Throwable;

final class AutenticacionRepository
{
    public function autenticar(string $usuario, string $password): array
    {
        try {
            $respuesta = (new SoapService(WebService::LOGIN))->call('Login', [
                'usuario' => $usuario,
                'password' => $password,
            ]);
        } catch (Throwable $exception) {
            throw new RuntimeException('No fue posible consultar el servicio de autenticación.', 0, $exception);
        }

        if (is_object($respuesta) && property_exists($respuesta, 'LoginResult')) {
            $respuesta = $respuesta->LoginResult;
        } elseif (is_array($respuesta) && array_key_exists('LoginResult', $respuesta)) {
            $respuesta = $respuesta['LoginResult'];
        }

        return [
            'exito' => filter_var($this->valor($respuesta, ['Exito', 'exito'], false), FILTER_VALIDATE_BOOL),
            'mensaje' => (string) $this->valor($respuesta, ['Mensaje', 'mensaje'], ''),
            'idUsuario' => (int) $this->valor($respuesta, ['IdUsuario', 'idUsuario'], 0),
            'usuario' => (string) $this->valor($respuesta, ['Usuario', 'usuario'], ''),
            'nombreCompleto' => (string) $this->valor($respuesta, ['NombreCompleto', 'nombreCompleto'], ''),
            'idRol' => (int) $this->valor($respuesta, ['IdRol', 'idRol'], 0),
            'nombreRol' => (string) $this->valor($respuesta, ['NombreRol', 'nombreRol'], ''),
            'estado' => (string) $this->valor($respuesta, ['Estado', 'estado'], ''),
        ];
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
