<?php

declare(strict_types=1);

namespace App\Repositories;

/**
 * Repositorio de Oferentes.
 *
 * ⚠️ MOCK TEMPORAL:
 * El acceso real a datos para este módulo será mediante un WEB SERVICE
 * que todavía no está implementado. Mientras no exista, este repositorio
 * devuelve datos simulados en PHP (array hardcoded), respetando la MISMA
 * regla de negocio que tendrá el SP real `sp_ObtenerOferentesPorPuesto`
 * (ver /sql/oferente_requisito.sql):
 *
 *   - Si el puesto tiene requisitos activos definidos: solo se listan
 *     los oferentes que cumplen TODOS esos requisitos.
 *   - Si el puesto NO tiene requisitos activos: se listan todos los
 *     oferentes (para no dejar la pantalla vacía).
 *
 * TODO: cuando el web service esté disponible, reemplazar el cuerpo de
 * obtenerPorPuesto() por una llamada HTTP (cURL/Guzzle) a ese servicio,
 * manteniendo la misma firma del método. Ni OferenteController ni la
 * vista deberían necesitar cambios cuando eso ocurra.
 */
final class OferenteRepository
{
    /**
     * Oferentes de prueba, tomados de la BD real de referencia
     * (tabla `personas` con tipo_perso = 'Oferente' + `oferentes`).
     */
    private const OFERENTES_MOCK = [
        ['id_oferente' => 4,  'identificacion' => '118760945',   'nombre_completo' => 'Carlos Andres Mora Solano'],
        ['id_oferente' => 5,  'identificacion' => '702340981',   'nombre_completo' => 'Maria Fernanda Rojas Vargas'],
        ['id_oferente' => 6,  'identificacion' => 'A12345678',   'nombre_completo' => 'Andres Felipe Castro Gomez'],
        ['id_oferente' => 7,  'identificacion' => '155812345678','nombre_completo' => 'Daniela Sofia Hernandez Ruiz'],
        ['id_oferente' => 8,  'identificacion' => '304560789',   'nombre_completo' => 'Valeria Jimenez Araya'],
        ['id_oferente' => 9,  'identificacion' => '205670432',   'nombre_completo' => 'Luis Diego Porras Salazar'],
        ['id_oferente' => 10, 'identificacion' => '109870654',   'nombre_completo' => 'Sofia Elena Vergara Mena'],
        ['id_oferente' => 11, 'identificacion' => 'B98765432',   'nombre_completo' => 'Ricardo Antonio Lopez Marin'],
        ['id_oferente' => 12, 'identificacion' => '155898765432','nombre_completo' => 'Camila Andrea Soto Peña'],
        ['id_oferente' => 13, 'identificacion' => '402780123',   'nombre_completo' => 'Jose Pablo Chaves Rojas'],
        ['id_oferente' => 14, 'identificacion' => '603450987',   'nombre_completo' => 'Natalia Fernanda Castro Mora'],
        ['id_oferente' => 15, 'identificacion' => 'C45678901',   'nombre_completo' => 'Gabriel Esteban Rojas Vega'],
        ['id_oferente' => 18, 'identificacion' => 'C45678902',   'nombre_completo' => 'Prueba OFETres'],
        ['id_oferente' => 19, 'identificacion' => '114365432',   'nombre_completo' => 'Julio Rosales'],
        ['id_oferente' => 20, 'identificacion' => '112545121',   'nombre_completo' => 'Kenneth Prueba Editado'],
    ];

    /**
     * Simula el resultado de `oferente_requisito` cruzado contra
     * `requisitos_puesto` para puestos que SÍ tienen requisitos activos.
     * Clave = codigo_puesto, valor = ids de oferentes que cumplen TODOS
     * los requisitos activos de ese puesto.
     */
    private const CUMPLIMIENTO_MOCK = [
        'GER005' => [14],  // id_puesto 4 -> 1 requisito activo, cumplido por oferente 14
        'GER008' => [15],  // id_puesto 5 -> 1 requisito activo (tras inactivar uno), cumplido por oferente 15
    ];

    /**
     * Puestos de prueba SIN requisitos activos (regla: se listan todos).
     * GER001 y P-2026-001 no tienen filas activas en requisitos_puesto.
     */
    private const PUESTOS_SIN_REQUISITOS = ['GER001', 'P-2026-001'];

    /**
     * Retorna los oferentes que cumplen los requisitos del puesto indicado.
     *
     * @param string $codigoPuesto Código de puesto ya validado/sanitizado.
     * @return array<int, array{id_oferente:int, identificacion:string, nombre_completo:string}>
     */
    public function obtenerPorPuesto(string $codigoPuesto): array
    {
        // TODO: reemplazar por llamada real al web service cuando exista.

        if (array_key_exists($codigoPuesto, self::CUMPLIMIENTO_MOCK)) {
            $idsQueCumplen = self::CUMPLIMIENTO_MOCK[$codigoPuesto];

            $resultado = array_values(array_filter(
                self::OFERENTES_MOCK,
                fn(array $oferente): bool => in_array($oferente['id_oferente'], $idsQueCumplen, true)
            ));

            return $this->ordenarPorNombre($resultado);
        }

        // Puesto sin requisitos definidos (incluye PUESTOS_SIN_REQUISITOS y
        // cualquier código no contemplado en el mock): se listan todos.
        return $this->ordenarPorNombre(self::OFERENTES_MOCK);
    }

    private function ordenarPorNombre(array $oferentes): array
    {
        usort($oferentes, fn(array $a, array $b) => $a['nombre_completo'] <=> $b['nombre_completo']);
        return $oferentes;
    }
}
