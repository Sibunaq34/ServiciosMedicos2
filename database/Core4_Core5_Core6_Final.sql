-- Script incremental e idempotente para CORE4, CORE5 y CORE6.
-- Esquema verificado: servicios; MariaDB local: puerto 3307.

DELIMITER $$

DROP PROCEDURE IF EXISTS `ValidarUsuario`$$
CREATE PROCEDURE `ValidarUsuario`(IN `pUsuario` VARCHAR(50))
BEGIN
    SELECT
        u.`id_usuario` AS `IdUsuario`,
        u.`usuario` AS `Usuario`,
        u.`nombre_completo` AS `NombreCompleto`,
        u.`contrasena` AS `PasswordCifrada`,
        u.`activo` AS `Activo`,
        u.`estado` AS `Estado`,
        COALESCE(u.`intentos_fallidos`, 0) AS `IntentosFallidos`,
        r.`id_rol` AS `IdRol`,
        r.`nombre_permiso` AS `NombreRol`
    FROM `usuarios` u
    INNER JOIN `usuariorol` ur ON ur.`id_usuario` = u.`id_usuario`
    INNER JOIN `roles` r ON r.`id_rol` = ur.`id_rol`
    WHERE LOWER(u.`usuario`) = LOWER(TRIM(`pUsuario`))
    ORDER BY r.`id_rol` ASC
    LIMIT 1;
END$$

DROP PROCEDURE IF EXISTS `RegistrarIntentoFallido`$$
CREATE PROCEDURE `RegistrarIntentoFallido`(IN `pIdUsuario` INT)
BEGIN
    UPDATE `usuarios`
    SET
        `intentos_fallidos` = LEAST(COALESCE(`intentos_fallidos`, 0) + 1, 3),
        `estado` = CASE WHEN `intentos_fallidos` >= 3 THEN 'Bloqueado' ELSE `estado` END,
        `activo` = CASE WHEN `intentos_fallidos` >= 3 THEN 0 ELSE `activo` END,
        `fecha_modifi` = NOW()
    WHERE `id_usuario` = `pIdUsuario`;

    SELECT COALESCE(`intentos_fallidos`, 0)
    FROM `usuarios`
    WHERE `id_usuario` = `pIdUsuario`;
END$$

DROP PROCEDURE IF EXISTS `ReiniciarIntentosFallidos`$$
CREATE PROCEDURE `ReiniciarIntentosFallidos`(IN `pIdUsuario` INT)
BEGIN
    UPDATE `usuarios`
    SET `intentos_fallidos` = 0, `fecha_access` = NOW()
    WHERE `id_usuario` = `pIdUsuario`;
END$$

DROP PROCEDURE IF EXISTS `ActualizarPasswordCifradaUsuario`$$
CREATE PROCEDURE `ActualizarPasswordCifradaUsuario`(
    IN `pIdUsuario` INT,
    IN `pPasswordCifrada` VARCHAR(255)
)
BEGIN
    UPDATE `usuarios`
    SET `contrasena` = `pPasswordCifrada`, `fecha_modifi` = NOW()
    WHERE `id_usuario` = `pIdUsuario`;
END$$

DROP PROCEDURE IF EXISTS `sp_Usuarios_CambiarEstado`$$
CREATE PROCEDURE `sp_Usuarios_CambiarEstado`(
    IN `p_idUsuario` INT,
    IN `p_estado` VARCHAR(20)
)
BEGIN
    UPDATE `usuarios`
    SET
        `estado` = CASE
            WHEN LOWER(TRIM(`p_estado`)) = 'activo' THEN 'Activo'
            ELSE 'Inactivo'
        END,
        `activo` = CASE
            WHEN LOWER(TRIM(`p_estado`)) = 'activo' THEN 1
            ELSE 0
        END,
        `intentos_fallidos` = CASE
            WHEN LOWER(TRIM(`p_estado`)) = 'activo' THEN 0
            ELSE COALESCE(`intentos_fallidos`, 0)
        END,
        `fecha_modifi` = NOW()
    WHERE `id_usuario` = `p_idUsuario`
      AND LOWER(TRIM(`p_estado`)) IN ('activo', 'inactivo');
END$$

DROP PROCEDURE IF EXISTS `SP_ListarPuestos`$$
CREATE PROCEDURE `SP_ListarPuestos`()
BEGIN
    SELECT
        p.`id_puesto` AS `IdPuesto`,
        p.`codigo_puesto` AS `CodigoPuesto`,
        p.`nombre_puesto` AS `NombrePuesto`,
        p.`monto_salario` AS `MontoSalario`,
        p.`id_puesto_jefac` AS `IdPuestoJefac`,
        j.`nombre_puesto` AS `Jefatura`
    FROM `puestos` p
    LEFT JOIN `puestos` j ON j.`id_puesto` = p.`id_puesto_jefac`
    WHERE p.`activo` = 1
    ORDER BY p.`nombre_puesto` ASC;
END$$

DELIMITER ;
