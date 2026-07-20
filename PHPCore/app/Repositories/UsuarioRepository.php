<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\WebService;
use App\Core\SoapService;
use RuntimeException;
use Throwable;

final class UsuarioRepository
{
    public function listar(): array
    {
        try {
            $respuesta = (new SoapService(WebService::USUARIOS))->call('ListarUsuarios');
            return $this->normalizarLista($respuesta);
        } catch (Throwable) {
            throw new RuntimeException('No fue posible consultar los usuarios.');
        }
    }

    public function crear(array $datos): array
    {
        try {
            $respuesta = (new SoapService(WebService::USUARIOS))->call('CrearUsuario', [
                'usuario' => (string) ($datos['usuario'] ?? ''),
                'password' => (string) ($datos['password'] ?? ''),
                'nombreCompleto' => (string) ($datos['nombreCompleto'] ?? ''),
                'correo' => (string) ($datos['correo'] ?? ''),
                'rol' => (string) ($datos['rol'] ?? ''),
                'estado' => (string) ($datos['estado'] ?? ''),
            ]);

            return $this->normalizarResultado($respuesta, 'Usuario creado correctamente.');
        } catch (Throwable) {
            return ['exito' => false, 'mensaje' => 'No fue posible crear el usuario.'];
        }
    }

    public function consultar(int $id): array
    {
        try {
            $respuesta = (new SoapService(WebService::USUARIOS))->call('ConsultarUsuario', [
                'id' => $id,
            ]);

            return $this->normalizarResultado($respuesta, 'Usuario encontrado.', true);
        } catch (Throwable) {
            return ['exito' => false, 'mensaje' => 'No fue posible consultar el usuario.'];
        }
    }

    public function editar(array $datos): array
    {
        try {
            $respuesta = (new SoapService(WebService::USUARIOS))->call('EditarUsuario', [
                'id' => (int) ($datos['id'] ?? 0),
                'usuario' => (string) ($datos['usuario'] ?? ''),
                'password' => (string) ($datos['password'] ?? ''),
                'nombreCompleto' => (string) ($datos['nombreCompleto'] ?? ''),
                'correo' => (string) ($datos['correo'] ?? ''),
                'rol' => (string) ($datos['rol'] ?? ''),
                'estado' => (string) ($datos['estado'] ?? ''),
            ]);

            return $this->normalizarResultado($respuesta, 'Usuario actualizado correctamente.');
        } catch (Throwable) {
            return ['exito' => false, 'mensaje' => 'No fue posible actualizar el usuario.'];
        }
    }

    public function cambiarEstado(int $id, string $estado): array
    {
        try {
            $respuesta = (new SoapService(WebService::USUARIOS))->call('CambiarEstadoUsuario', [
                'id' => $id,
                'estado' => $estado,
            ]);

            return $this->normalizarResultado($respuesta, 'Estado actualizado correctamente.');
        } catch (Throwable) {
            return ['exito' => false, 'mensaje' => 'No fue posible cambiar el estado del usuario.'];
        }
    }

    private function normalizarResultado(mixed $respuesta, string $mensajePredeterminada, bool $conDatos = false): array
    {
        if (is_object($respuesta) && property_exists($respuesta, 'ListarUsuariosResult')) {
            $respuesta = $respuesta->ListarUsuariosResult;
        } elseif (is_object($respuesta) && property_exists($respuesta, 'CrearUsuarioResult')) {
            $respuesta = $respuesta->CrearUsuarioResult;
        } elseif (is_object($respuesta) && property_exists($respuesta, 'ConsultarUsuarioResult')) {
            $respuesta = $respuesta->ConsultarUsuarioResult;
        } elseif (is_object($respuesta) && property_exists($respuesta, 'EditarUsuarioResult')) {
            $respuesta = $respuesta->EditarUsuarioResult;
        } elseif (is_object($respuesta) && property_exists($respuesta, 'CambiarEstadoUsuarioResult')) {
            $respuesta = $respuesta->CambiarEstadoUsuarioResult;
        }

        $exito = filter_var($this->valor($respuesta, ['Exito', 'exito'], false), FILTER_VALIDATE_BOOL);
        $mensaje = (string) $this->valor($respuesta, ['Mensaje', 'mensaje'], $mensajePredeterminada);
        $datos = [];
        if ($conDatos) {
            $datos = $this->normalizarRegistro($respuesta);
        }

        return ['exito' => $exito, 'mensaje' => $mensaje, 'datos' => $datos];
    }

    private function normalizarLista(mixed $respuesta): array
    {
        if (is_object($respuesta) && property_exists($respuesta, 'ListarUsuariosResult')) {
            $respuesta = $respuesta->ListarUsuariosResult;
        }

        if (is_object($respuesta)) {
            $respuesta = [$respuesta];
        }

        if (!is_array($respuesta)) {
            return [];
        }

        return array_values(array_map(fn($item) => $this->normalizarRegistro($item), $respuesta));
    }

    private function normalizarRegistro(mixed $registro): array
    {
        if (!is_object($registro)) {
            return [];
        }

        return [
            'id' => (int) $this->valor($registro, ['Id', 'id'], 0),
            'usuario' => (string) $this->valor($registro, ['Usuario', 'usuario'], ''),
            'nombreCompleto' => (string) $this->valor($registro, ['NombreCompleto', 'nombreCompleto'], ''),
            'correo' => (string) $this->valor($registro, ['Correo', 'correo'], ''),
            'rol' => (string) $this->valor($registro, ['Rol', 'rol'], ''),
            'estado' => (string) $this->valor($registro, ['Estado', 'estado'], ''),
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
