-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3307
-- Tiempo de generación: 18-07-2026 a las 06:04:14
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `servicios`
--
CREATE DATABASE IF NOT EXISTS `servicios` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `servicios`;

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarParametro` (IN `pIdParametro` INT, IN `pCodigoParametro` VARCHAR(100), IN `pValor` VARCHAR(500))   BEGIN
    UPDATE Parametros
    SET
        codigo_parametro = pCodigoParametro,
        valor = pValor
    WHERE id_parametro = pIdParametro;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarBitacoras` (IN `pUsuario` VARCHAR(50), IN `pDescripcion` VARCHAR(255), IN `pPagina` INT, IN `pTamanoPagina` INT)   BEGIN

    DECLARE vOffset INT;

    SET vOffset = (pPagina - 1) * pTamanoPagina;


    SELECT
        b.id_bitacoras,
        b.fecha_bitacora,
        u.usuario,
        b.accion,
        b.descripcionAccion

    FROM bitacoras b

    INNER JOIN Usuarios u
        ON b.id_usuario = u.id_usuario

    WHERE
        (
            pUsuario IS NULL
            OR pUsuario = ''
            OR u.usuario LIKE CONCAT('%', pUsuario, '%')
        )

    AND

        (
            pDescripcion IS NULL
            OR pDescripcion = ''
            OR CAST(b.descripcionAccion AS CHAR) LIKE CONCAT('%', pDescripcion, '%')
        )

    ORDER BY b.fecha_bitacora DESC

    LIMIT pTamanoPagina OFFSET vOffset;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarParametro` (IN `pIdParametro` INT)   BEGIN
    DELETE FROM Parametros
    WHERE id_parametro = pIdParametro;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GuardarUbicacion` (IN `pProvincia` VARCHAR(100), IN `pCanton` VARCHAR(100), IN `pDistrito` VARCHAR(100))   BEGIN

    IF NOT EXISTS(
        SELECT 1
        FROM Provincias
        WHERE nombre = pProvincia
    ) THEN

        INSERT INTO Provincias(nombre)
        VALUES(pProvincia);

    END IF;

    IF NOT EXISTS(
        SELECT 1
        FROM Canton
        WHERE nombre = pCanton
    ) THEN

        INSERT INTO Canton(nombre)
        VALUES(pCanton);

    END IF;

    IF NOT EXISTS(
        SELECT 1
        FROM Distrito
        WHERE nombre = pDistrito
    ) THEN

        INSERT INTO Distrito(nombre)
        VALUES(pDistrito);

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarParametro` (IN `pCodigoParametro` VARCHAR(100), IN `pValor` VARCHAR(500))   BEGIN
    INSERT INTO Parametros(
        codigo_parametro,
        valor
    )
    VALUES(
        pCodigoParametro,
        pValor
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ListarParametros` (IN `pPagina` INT, IN `pTamanoPagina` INT)   BEGIN

    DECLARE vOffset INT;

    SET vOffset = (pPagina - 1) * pTamanoPagina;


    SELECT
        id_parametro AS IdParametro,
        codigo_parametro AS CodigoParametro,
        valor AS Valor

    FROM Parametros

    ORDER BY codigo_parametro

    LIMIT pTamanoPagina OFFSET vOffset;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ObtenerParametroPorCodigo` (IN `pCodigoParametro` VARCHAR(100))   BEGIN
    SELECT
        id_parametro AS IdParametro,
        codigo_parametro AS CodigoParametro,
        valor AS Valor
    FROM Parametros
    WHERE codigo_parametro = pCodigoParametro
    LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ObtenerParametroPorId` (IN `pIdParametro` INT)   BEGIN
    SELECT
        id_parametro AS IdParametro,
        codigo_parametro AS CodigoParametro,
        valor AS Valor
    FROM Parametros
    WHERE id_parametro = pIdParametro;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarIntentoFallido` (IN `pIdUsuario` INT, IN `pIntentos` INT)   BEGIN

    UPDATE Usuarios
    SET intentos_fallidos = pIntentos,
        estado = CASE
                    WHEN pIntentos >= 3 THEN "Inactivo"
                    ELSE "Activo"
                 END
    WHERE id_usuario = pIdUsuario;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ActualizarAccionPersonal` (IN `pIdAccion` INT, IN `pFecha` DATE, IN `pDescripcion` VARCHAR(500), IN `pIdEmpleado` INT, IN `pIdJefatura` INT)   BEGIN

    UPDATE Accion_personal
    SET
        fecha_accion = pFecha,
        descripcion = pDescripcion,
        id_empleado = pIdEmpleado,
        id_jefactura = pIdJefatura,
        fecha_modificacion = CURDATE()
    WHERE id_accion = pIdAccion;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ActualizarPuesto` (IN `pIdPuesto` INT, IN `pCodigo` VARCHAR(20), IN `pNombre` VARCHAR(150), IN `pSalario` DECIMAL(12,2), IN `pIdJefatura` INT)   BEGIN

    UPDATE Puestos
    SET
        codigo_puesto = pCodigo,
        nombre_puesto = pNombre,
        monto_salario = pSalario,
        id_puesto_jefac = pIdJefatura,
        fecha_modificacion = NOW()
    WHERE id_puesto = pIdPuesto;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ActualizarRequisito` (IN `pIdRequisito` INT, IN `pNombreRequisito` VARCHAR(100))   BEGIN

    UPDATE Requisitos_Puesto
    SET
        nombre_requisito = pNombreRequisito,
        fecha_modificacion = NOW()
    WHERE id_requisito = pIdRequisito;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Actualizar_Area` (IN `p_id_area` INT, IN `p_codigo_area` VARCHAR(20), IN `p_nombre_area` VARCHAR(100), IN `p_id_empleado` INT)   BEGIN
    UPDATE admin_area
    SET codigo_area = p_codigo_area,
        nombre_area = p_nombre_area,
        id_empleado = p_id_empleado
    WHERE id_area = p_id_area;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Actualizar_Compania` (IN `p_id_compania` INT, IN `p_codigo_compania` VARCHAR(50), IN `p_nombre` VARCHAR(150))   BEGIN
    UPDATE companias
    SET codigo_compania = p_codigo_compania,
        nombre          = p_nombre
    WHERE id_compania = p_id_compania;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Actualizar_Entrevista` (IN `p_id_entrevista` INT, IN `p_id_empleado` INT, IN `p_fecha_entrevista` DATETIME)   BEGIN
    UPDATE entrevistas
    SET id_empleado      = p_id_empleado,
        fecha_entrevista = p_fecha_entrevista
    WHERE id_entrevista = p_id_entrevista;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Actualizar_Experiencia_Laboal` (IN `p_id_experiencia` INT, IN `p_nombre_empresa` VARCHAR(100), IN `p_puesto_desempenado` VARCHAR(100), IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE)   BEGIN
    UPDATE experiencia_laboral
    SET
        nombre_empresa     = p_nombre_empresa,
        puesto_desempenado = p_puesto_desempenado,
        fecha_inicio       = p_fecha_inicio,
        fecha_fin          = p_fecha_fin
    WHERE id_experiencia = p_id_experiencia;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CodigoExiste_Area` (IN `p_codigo_area` VARCHAR(20), IN `p_id_area` INT, OUT `p_existe` TINYINT)   BEGIN
    SELECT COUNT(*) INTO p_existe
    FROM admin_area
    WHERE codigo_area = p_codigo_area
      AND id_area != IFNULL(p_id_area, 0);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CodigoExiste_Compania` (IN `p_codigo_compania` VARCHAR(50), IN `p_id_compania` INT, OUT `p_existe` TINYINT)   BEGIN
    SELECT COUNT(*) INTO p_existe
    FROM companias
    WHERE codigo_compania = p_codigo_compania
      AND id_compania != IFNULL(p_id_compania, 0);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_concursos_actualizar` (IN `pIdConcurso` INT, IN `pCodigo` VARCHAR(30), IN `pNombre` VARCHAR(150), IN `pFechaInicio` DATE, IN `pFechaFin` DATE, IN `pEstado` VARCHAR(20), IN `pIdUsuario` INT)   BEGIN
    DECLARE vAnterior LONGTEXT;
    DECLARE vActual LONGTEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pIdConcurso IS NULL OR pIdConcurso <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El concurso es requerido.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Concursos
        WHERE id_concursos = pIdConcurso
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El concurso no existe.';
    END IF;

    IF pCodigo IS NULL OR TRIM(pCodigo) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El codigo del concurso es requerido.';
    END IF;

    IF pNombre IS NULL OR TRIM(pNombre) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre del concurso es requerido.';
    END IF;

    IF pFechaInicio IS NULL OR pFechaFin IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Las fechas del concurso son requeridas.';
    END IF;

    IF pFechaFin < pFechaInicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de fin debe ser mayor o igual a la fecha de inicio.';
    END IF;

    IF pEstado IS NULL OR pEstado NOT IN ('Vigente', 'Vencido') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El estado del concurso debe ser Vigente o Vencido.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Concursos
        WHERE codigo_concurso = TRIM(pCodigo)
          AND id_concursos <> pIdConcurso
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El codigo del concurso ya existe.';
    END IF;

    SELECT JSON_OBJECT(
        'idConcurso', id_concursos,
        'codigo', codigo_concurso,
        'nombre', nombre_concurso,
        'fechaInicio', fecha_inicio,
        'fechaFin', fecha_fin,
        'estado', estado_concur
    )
    INTO vAnterior
    FROM Concursos
    WHERE id_concursos = pIdConcurso;

    START TRANSACTION;

    UPDATE Concursos
    SET
        codigo_concurso = TRIM(pCodigo),
        nombre_concurso = TRIM(pNombre),
        fecha_inicio = pFechaInicio,
        fecha_fin = pFechaFin,
        estado_concur = pEstado
    WHERE id_concursos = pIdConcurso;

    SELECT JSON_OBJECT(
        'idConcurso', id_concursos,
        'codigo', codigo_concurso,
        'nombre', nombre_concurso,
        'fechaInicio', fecha_inicio,
        'fechaFin', fecha_fin,
        'estado', estado_concur
    )
    INTO vActual
    FROM Concursos
    WHERE id_concursos = pIdConcurso;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Actualizar OFE2',
        JSON_OBJECT(
            'mensaje', 'Se actualiza concurso',
            'anterior', JSON_EXTRACT(vAnterior, '$'),
            'actual', JSON_EXTRACT(vActual, '$')
        )
    );

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_concursos_cambiar_estado` (IN `pIdConcurso` INT, IN `pEstado` VARCHAR(20), IN `pIdUsuario` INT)   BEGIN
    DECLARE vEstadoAnterior VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pIdConcurso IS NULL OR pIdConcurso <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El concurso es requerido.';
    END IF;

    IF pEstado IS NULL OR pEstado NOT IN ('Vigente', 'Vencido') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El estado del concurso debe ser Vigente o Vencido.';
    END IF;

    SELECT estado_concur
    INTO vEstadoAnterior
    FROM Concursos
    WHERE id_concursos = pIdConcurso;

    IF vEstadoAnterior IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El concurso no existe.';
    END IF;

    START TRANSACTION;

    UPDATE Concursos
    SET estado_concur = pEstado
    WHERE id_concursos = pIdConcurso;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Cambiar estado OFE2',
        JSON_OBJECT(
            'mensaje', 'Se cambia estado de concurso',
            'idConcurso', pIdConcurso,
            'estadoAnterior', vEstadoAnterior,
            'estadoActual', pEstado
        )
    );

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_concursos_crear` (IN `pCodigo` VARCHAR(30), IN `pNombre` VARCHAR(150), IN `pFechaInicio` DATE, IN `pFechaFin` DATE, IN `pIdUsuario` INT)   BEGIN
    DECLARE vIdConcurso INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pCodigo IS NULL OR TRIM(pCodigo) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El codigo del concurso es requerido.';
    END IF;

    IF pNombre IS NULL OR TRIM(pNombre) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre del concurso es requerido.';
    END IF;

    IF pFechaInicio IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de inicio del concurso es requerida.';
    END IF;

    IF pFechaFin IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de fin del concurso es requerida.';
    END IF;

    IF pFechaFin < pFechaInicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de fin debe ser mayor o igual a la fecha de inicio.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Concursos
        WHERE codigo_concurso = TRIM(pCodigo)
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El codigo del concurso ya existe.';
    END IF;

    START TRANSACTION;

    INSERT INTO Concursos(
        codigo_concurso,
        nombre_concurso,
        fecha_inicio,
        fecha_fin,
        estado_concur
    )
    VALUES (
        TRIM(pCodigo),
        TRIM(pNombre),
        pFechaInicio,
        pFechaFin,
        'Vigente'
    );

    SET vIdConcurso = LAST_INSERT_ID();

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Crear OFE2',
        JSON_OBJECT(
            'mensaje', 'Se crea concurso',
            'registro', JSON_OBJECT(
                'idConcurso', vIdConcurso,
                'codigo', TRIM(pCodigo),
                'nombre', TRIM(pNombre),
                'fechaInicio', pFechaInicio,
                'fechaFin', pFechaFin,
                'estado', 'Vigente'
            )
        )
    );

    COMMIT;

    SELECT vIdConcurso AS IdConcurso;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_concursos_eliminar` (IN `pIdConcurso` INT, IN `pIdUsuario` INT)   BEGIN
    DECLARE vAnterior LONGTEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pIdConcurso IS NULL OR pIdConcurso <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El concurso es requerido.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Concursos
        WHERE id_concursos = pIdConcurso
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El concurso no existe.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Oferente_concur
        WHERE id_concursos = pIdConcurso
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar un registro con datos relacionados.';
    END IF;

    SELECT JSON_OBJECT(
        'idConcurso', id_concursos,
        'codigo', codigo_concurso,
        'nombre', nombre_concurso,
        'fechaInicio', fecha_inicio,
        'fechaFin', fecha_fin,
        'estado', estado_concur
    )
    INTO vAnterior
    FROM Concursos
    WHERE id_concursos = pIdConcurso;

    START TRANSACTION;

    DELETE FROM Concursos
    WHERE id_concursos = pIdConcurso;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Eliminar OFE2',
        JSON_OBJECT(
            'mensaje', 'Se elimina concurso',
            'registroEliminado', JSON_EXTRACT(vAnterior, '$')
        )
    );

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_concursos_listar` (IN `pPagina` INT, IN `pTamanoPagina` INT, IN `pIdUsuario` INT)   BEGIN
    DECLARE vPagina INT DEFAULT 1;
    DECLARE vTamanoPagina INT DEFAULT 10;
    DECLARE vOffset INT DEFAULT 0;

    SET vPagina = IFNULL(NULLIF(pPagina, 0), 1);
    SET vTamanoPagina = IFNULL(NULLIF(pTamanoPagina, 0), 10);

    IF vPagina < 1 THEN
        SET vPagina = 1;
    END IF;

    IF vTamanoPagina < 1 THEN
        SET vTamanoPagina = 10;
    END IF;

    SET vOffset = (vPagina - 1) * vTamanoPagina;

    SELECT
        id_concursos AS IdConcurso,
        codigo_concurso AS Codigo,
        nombre_concurso AS Nombre,
        fecha_inicio AS FechaInicio,
        fecha_fin AS FechaFin,
        estado_concur AS Estado
    FROM Concursos
    ORDER BY fecha_inicio DESC, nombre_concurso ASC
    LIMIT vTamanoPagina OFFSET vOffset;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Consultar OFE2',
        JSON_OBJECT(
            'mensaje', 'El usuario consulta concursos',
            'pagina', vPagina,
            'tamanoPagina', vTamanoPagina
        )
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_concursos_obtener` (IN `pIdConcurso` INT, IN `pIdUsuario` INT)   BEGIN
    IF pIdConcurso IS NULL OR pIdConcurso <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El concurso es requerido.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Concursos
        WHERE id_concursos = pIdConcurso
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El concurso no existe.';
    END IF;

    SELECT
        id_concursos AS IdConcurso,
        codigo_concurso AS Codigo,
        nombre_concurso AS Nombre,
        fecha_inicio AS FechaInicio,
        fecha_fin AS FechaFin,
        estado_concur AS Estado
    FROM Concursos
    WHERE id_concursos = pIdConcurso;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Consultar OFE2',
        JSON_OBJECT(
            'mensaje', 'El usuario consulta un concurso',
            'idConcurso', pIdConcurso
        )
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ContratarEmpleado` (IN `pIdOferente` INT, IN `pIdPuesto` INT, IN `pIdJefatura` INT)   BEGIN

    DECLARE vNombre VARCHAR(200);
    DECLARE vIdentificacion VARCHAR(20);
    DECLARE vTipoIdentificacion VARCHAR(20);
    DECLARE vEmpleado INT;

    SELECT
        p.nombre_comple,
        p.identificacion,
        p.tipo_identificacion
    INTO
        vNombre,
        vIdentificacion,
        vTipoIdentificacion
    FROM Oferentes o
    INNER JOIN Personas p
        ON o.id_persona = p.id_persona
    WHERE o.id_oferente = pIdOferente;

    INSERT INTO Empleados(
        numero_empleado,
        id_oferente,
        fecha_creacion,
        nombre_completo,
        identificacion,
        tipo_identificacion,
        id_puesto,
        fecha_contratacion,
        estado
    )
    VALUES(
        CONCAT('EMP-', DATE_FORMAT(NOW(),'%Y%m%d%H%i%s')),
        pIdOferente,
        CURDATE(),
        vNombre,
        vIdentificacion,
        vTipoIdentificacion,
        pIdPuesto,
        CURDATE(),
        'activo'
    );

    SET vEmpleado = LAST_INSERT_ID();

    INSERT INTO Accion_personal(
        codigo_accion,
        fecha_accion,
        descripcion,
        id_empleado,
        id_jefactura,
        fecha_creacion,
        activo
    )
    VALUES(
        CONCAT('CON-', vEmpleado),
        CURDATE(),
        'Contratación de empleado',
        vEmpleado,
        pIdJefatura,
        CURDATE(),
        1
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_EliminarAccionPersonal` (IN `pIdAccion` INT)   BEGIN

    UPDATE Accion_personal
    SET
        activo = 0,
        fecha_modificacion = CURDATE()
    WHERE id_accion = pIdAccion;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_EliminarPuesto` (IN `pIdPuesto` INT)   BEGIN

    UPDATE Puestos
    SET
        activo = 0,
        fecha_modificacion = NOW()
    WHERE id_puesto = pIdPuesto;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_EliminarRequisito` (IN `pIdRequisito` INT)   BEGIN

    UPDATE Requisitos_Puesto
    SET
        activo = 0,
        fecha_modificacion = NOW()
    WHERE id_requisito = pIdRequisito;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Eliminar_Area` (IN `p_id_area` INT)   BEGIN
    DELETE FROM admin_area WHERE id_area = p_id_area;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Eliminar_Compania` (IN `p_id_compania` INT)   BEGIN
    DELETE FROM companias WHERE id_compania = p_id_compania;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Eliminar_Entrevista` (IN `p_id_entrevista` INT)   BEGIN
    DELETE FROM entrevistas WHERE id_entrevista = p_id_entrevista;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Eliminar_Experiencia_Laboral` (IN `p_id_experiencia` INT)   BEGIN
    DELETE FROM experiencia_laboral
    WHERE id_experiencia = p_id_experiencia;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_InsertarAccionPersonal` (IN `pFecha` DATE, IN `pDescripcion` VARCHAR(500), IN `pIdEmpleado` INT, IN `pIdJefatura` INT)   BEGIN

    INSERT INTO Accion_personal(
        codigo_accion,
        fecha_accion,
        descripcion,
        id_empleado,
        id_jefactura,
        fecha_creacion,
        activo
    )
    VALUES(
        CONCAT('ACC-', UNIX_TIMESTAMP()),
        pFecha,
        pDescripcion,
        pIdEmpleado,
        pIdJefatura,
        CURDATE(),
        1
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_InsertarPuesto` (IN `pCodigo` VARCHAR(20), IN `pNombre` VARCHAR(150), IN `pSalario` DECIMAL(12,2), IN `pIdJefatura` INT)   BEGIN

    INSERT INTO Puestos(
        codigo_puesto,
        nombre_puesto,
        monto_salario,
        id_puesto_jefac,
        fecha_creacion,
        activo
    )
    VALUES(
        pCodigo,
        pNombre,
        pSalario,
        pIdJefatura,
        NOW(),
        1
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_InsertarRequisito` (IN `pIdPuesto` INT, IN `pNombreRequisito` VARCHAR(100))   BEGIN

    INSERT INTO Requisitos_Puesto(
        id_puesto,
        nombre_requisito,
        fecha_creacion,
        activo
    )
    VALUES(
        pIdPuesto,
        pNombreRequisito,
        NOW(),
        1
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Insertar_Area` (IN `p_codigo_area` VARCHAR(20), IN `p_nombre_area` VARCHAR(100), IN `p_id_empleado` INT, OUT `p_id_area` INT)   BEGIN
    INSERT INTO admin_area (codigo_area, nombre_area, id_empleado, activon)
    VALUES (p_codigo_area, p_nombre_area, p_id_empleado, 1);

    SET p_id_area = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Insertar_Compania` (IN `p_codigo_compania` VARCHAR(50), IN `p_nombre` VARCHAR(150), OUT `p_id_compania` INT)   BEGIN
    INSERT INTO companias (codigo_compania, nombre)
    VALUES (p_codigo_compania, p_nombre);

    SET p_id_compania = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Insertar_Entrevista` (IN `p_id_oferente` INT, IN `p_id_empleado` INT, IN `p_fecha_entrevista` DATETIME, OUT `p_id_entrevista` INT)   BEGIN
    INSERT INTO entrevistas (id_oferente, id_empleado, fecha_entrevista, estado)
    VALUES (p_id_oferente, p_id_empleado, p_fecha_entrevista, 'Pendiente');

    SET p_id_entrevista = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Insertar_Experiencia_Laboral` (IN `p_id_oferente` INT, IN `p_nombre_empresa` VARCHAR(100), IN `p_puesto_desempenado` VARCHAR(100), IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE, OUT `p_id_experiencia` INT)   BEGIN
    INSERT INTO experiencia_laboral
        (id_oferente, nombre_empresa, puesto_desempenado, fecha_inicio, fecha_fin)
    VALUES
        (p_id_oferente, p_nombre_empresa, p_puesto_desempenado, p_fecha_inicio, p_fecha_fin);

    SET p_id_experiencia = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_instituciones_actualizar` (IN `pIdInstitucion` INT, IN `pCodigo` VARCHAR(30), IN `pNombre` VARCHAR(150), IN `pIdUsuario` INT)   BEGIN
    DECLARE vAnterior LONGTEXT;
    DECLARE vActual LONGTEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pIdInstitucion IS NULL OR pIdInstitucion <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La institucion educativa es requerida.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM institu_educa
        WHERE id_insti_edu = pIdInstitucion
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La institucion educativa no existe.';
    END IF;

    IF pCodigo IS NULL OR TRIM(pCodigo) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El codigo de la institucion es requerido.';
    END IF;

    IF pNombre IS NULL OR TRIM(pNombre) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre de la institucion es requerido.';
    END IF;

    IF CHAR_LENGTH(TRIM(pNombre)) > 150 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre de la institucion no puede superar 150 caracteres.';
    END IF;

    IF TRIM(pNombre) NOT REGEXP '^[A-Za-zÁÉÍÓÚáéíóúÑñÜü ]+$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre solo puede contener letras y espacios.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM institu_educa
        WHERE codigo_insti = TRIM(pCodigo)
          AND id_insti_edu <> pIdInstitucion
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El codigo de la institucion ya existe.';
    END IF;

    SELECT JSON_OBJECT(
        'idInstitucion', id_insti_edu,
        'codigo', codigo_insti,
        'nombre', nombre
    )
    INTO vAnterior
    FROM institu_educa
    WHERE id_insti_edu = pIdInstitucion;

    START TRANSACTION;

    UPDATE institu_educa
    SET
        codigo_insti = TRIM(pCodigo),
        nombre = TRIM(pNombre)
    WHERE id_insti_edu = pIdInstitucion;

    SELECT JSON_OBJECT(
        'idInstitucion', id_insti_edu,
        'codigo', codigo_insti,
        'nombre', nombre
    )
    INTO vActual
    FROM institu_educa
    WHERE id_insti_edu = pIdInstitucion;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Actualizar GEN5',
        JSON_OBJECT(
            'mensaje', 'Se actualiza institucion educativa',
            'anterior', JSON_EXTRACT(vAnterior, '$'),
            'actual', JSON_EXTRACT(vActual, '$')
        )
    );

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_instituciones_crear` (IN `pCodigo` VARCHAR(30), IN `pNombre` VARCHAR(150), IN `pIdUsuario` INT)   BEGIN
    DECLARE vIdInstitucion INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pCodigo IS NULL OR TRIM(pCodigo) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El codigo de la institucion es requerido.';
    END IF;

    IF pNombre IS NULL OR TRIM(pNombre) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre de la institucion es requerido.';
    END IF;

    IF CHAR_LENGTH(TRIM(pNombre)) > 150 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre de la institucion no puede superar 150 caracteres.';
    END IF;

    IF TRIM(pNombre) NOT REGEXP '^[A-Za-zÁÉÍÓÚáéíóúÑñÜü ]+$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre solo puede contener letras y espacios.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM institu_educa
        WHERE codigo_insti = TRIM(pCodigo)
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El codigo de la institucion ya existe.';
    END IF;

    START TRANSACTION;

    INSERT INTO institu_educa(codigo_insti, nombre)
    VALUES (TRIM(pCodigo), TRIM(pNombre));

    SET vIdInstitucion = LAST_INSERT_ID();

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Crear GEN5',
        JSON_OBJECT(
            'mensaje', 'Se crea institucion educativa',
            'registro', JSON_OBJECT(
                'idInstitucion', vIdInstitucion,
                'codigo', TRIM(pCodigo),
                'nombre', TRIM(pNombre)
            )
        )
    );

    COMMIT;

    SELECT vIdInstitucion AS IdInstitucion;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_instituciones_eliminar` (IN `pIdInstitucion` INT, IN `pIdUsuario` INT)   BEGIN
    DECLARE vAnterior LONGTEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pIdInstitucion IS NULL OR pIdInstitucion <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La institucion educativa es requerida.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Institu_educa
        WHERE id_insti_edu = pIdInstitucion
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La institucion educativa no existe.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Prepara_academica
        WHERE id_insti_edu = pIdInstitucion
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar un registro con datos relacionados.';
    END IF;

    SELECT JSON_OBJECT(
        'idInstitucion', id_insti_edu,
        'codigo', codigo_insti,
        'nombre', nombre
    )
    INTO vAnterior
    FROM Institu_educa
    WHERE id_insti_edu = pIdInstitucion;

    START TRANSACTION;

    DELETE FROM Institu_educa
    WHERE id_insti_edu = pIdInstitucion;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Eliminar GEN5',
        JSON_OBJECT(
            'mensaje', 'Se elimina institucion educativa',
            'registroEliminado', JSON_EXTRACT(vAnterior, '$')
        )
    );

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_instituciones_listar` (IN `pPagina` INT, IN `pTamanoPagina` INT, IN `pIdUsuario` INT)   BEGIN
    DECLARE vPagina INT DEFAULT 1;
    DECLARE vTamanoPagina INT DEFAULT 10;
    DECLARE vOffset INT DEFAULT 0;

    SET vPagina = IFNULL(NULLIF(pPagina, 0), 1);
    SET vTamanoPagina = IFNULL(NULLIF(pTamanoPagina, 0), 10);

    IF vPagina < 1 THEN
        SET vPagina = 1;
    END IF;

    IF vTamanoPagina < 1 THEN
        SET vTamanoPagina = 10;
    END IF;

    SET vOffset = (vPagina - 1) * vTamanoPagina;

    SELECT
        id_insti_edu AS IdInstitucion,
        codigo_insti AS Codigo,
        nombre AS Nombre
    FROM Institu_educa
    ORDER BY nombre ASC
    LIMIT vTamanoPagina OFFSET vOffset;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Consultar GEN5',
        JSON_OBJECT(
            'mensaje', 'El usuario consulta instituciones educativas',
            'pagina', vPagina,
            'tamanoPagina', vTamanoPagina
        )
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_instituciones_obtener` (IN `pIdInstitucion` INT, IN `pIdUsuario` INT)   BEGIN
    IF pIdInstitucion IS NULL OR pIdInstitucion <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La institucion educativa es requerida.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Institu_educa
        WHERE id_insti_edu = pIdInstitucion
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La institucion educativa no existe.';
    END IF;

    SELECT
        id_insti_edu AS IdInstitucion,
        codigo_insti AS Codigo,
        nombre AS Nombre
    FROM Institu_educa
    WHERE id_insti_edu = pIdInstitucion;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Consultar GEN5',
        JSON_OBJECT(
            'mensaje', 'El usuario consulta una institucion educativa',
            'idInstitucion', pIdInstitucion
        )
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ListarAccionesPersonal` ()   BEGIN

    SELECT
        ap.id_accion,
        ap.codigo_accion,
        ap.fecha_accion,
        ap.descripcion,
        e.nombre_completo AS empleado,
        j.nombre_completo AS jefatura
    FROM Accion_personal ap
    INNER JOIN Empleados e
        ON ap.id_empleado = e.id_empleado
    INNER JOIN Empleados j
        ON ap.id_jefactura = j.id_empleado
    WHERE ap.activo = 1
    ORDER BY ap.fecha_accion DESC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ListarEmpleados` ()   BEGIN
   SELECT
    id_empleado,
    nombre_completo
  FROM Empleados
   ORDER BY nombre_completo;
  END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ListarOferentes` ()   BEGIN
     SELECT
		o.id_oferente,
     p.nombre_comple AS nombre_completo
   FROM Oferentes o
   INNER JOIN Personas p
     ON o.id_persona = p.id_persona
  ORDER BY p.nombre_comple;
  END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ListarPuestos` ()   BEGIN

    SELECT
        p.id_puesto,
        p.codigo_puesto,
        p.nombre_puesto,
        p.monto_salario,
        j.nombre_puesto AS jefatura
    FROM Puestos p
    LEFT JOIN Puestos j
        ON p.id_puesto_jefac = j.id_puesto
    WHERE p.activo = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ListarRequisitos` (IN `pIdPuesto` INT)   BEGIN
    SELECT
          id_requisito,
		id_puesto,
          nombre_requisito
	FROM Requisitos_Puesto
	WHERE id_puesto = pIdPuesto
         AND activo = 1;
   END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Lista_Area` (IN `p_pagina` INT, IN `p_tamano` INT)   BEGIN
    DECLARE v_offset INT;
    SET v_offset = (p_pagina - 1) * p_tamano;

    SELECT
        a.id_area,
        a.codigo_area,
        a.nombre_area,
        a.id_empleado,
        e.nombre_completo AS nombre_empleado
    FROM admin_area a
    LEFT JOIN empleados e ON a.id_empleado = e.id_empleado
    ORDER BY a.codigo_area
    LIMIT p_tamano OFFSET v_offset;

    SELECT COUNT(*) AS Total FROM admin_area;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Lista_Compania` (IN `p_pagina` INT, IN `p_tamano` INT)   BEGIN
    DECLARE v_offset INT;
    SET v_offset = (p_pagina - 1) * p_tamano;

    SELECT
        id_compania,
        codigo_compania,
        nombre
    FROM companias
    ORDER BY codigo_compania
    LIMIT p_tamano OFFSET v_offset;

    SELECT COUNT(*) AS Total FROM companias;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Lista_Entrevista` (IN `p_pagina` INT, IN `p_tamano` INT)   BEGIN
    DECLARE v_offset INT;
    SET v_offset = (p_pagina - 1) * p_tamano;

    SELECT
        e.id_entrevista,
        e.id_oferente,
        p.nombre_comple      AS nombre_oferente,
        e.id_empleado,
        emp.nombre_completo  AS nombre_empleado,
        e.fecha_entrevista,
        e.estado
    FROM entrevistas e
    INNER JOIN oferentes o   ON e.id_oferente = o.id_oferente
    INNER JOIN personas p    ON o.id_persona  = p.id_persona
    INNER JOIN empleados emp ON e.id_empleado = emp.id_empleado
    ORDER BY e.fecha_entrevista ASC
    LIMIT p_tamano OFFSET v_offset;

    SELECT COUNT(*) AS Total FROM entrevistas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Lista_Experiencia_Laboral` (IN `p_id_oferente` INT, IN `p_pagina` INT, IN `p_tamano` INT)   BEGIN
    DECLARE v_offset INT;
    SET v_offset = (p_pagina - 1) * p_tamano;

    SELECT
        id_experiencia,
        id_oferente,
        nombre_empresa,
        puesto_desempenado,
        fecha_inicio,
        fecha_fin
    FROM experiencia_laboral
    WHERE id_oferente = p_id_oferente
    ORDER BY fecha_inicio DESC
    LIMIT p_tamano OFFSET v_offset;

    SELECT COUNT(*) AS Total
    FROM experiencia_laboral
    WHERE id_oferente = p_id_oferente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_MarcarRealizada_Entrevista` (IN `p_id_entrevista` INT)   BEGIN
    UPDATE entrevistas
    SET estado = 'Realizada'
    WHERE id_entrevista = p_id_entrevista;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ObtenerEmpleados_Area` ()   BEGIN
    SELECT id_empleado, nombre_completo
    FROM empleados
    WHERE estado = 'activo'
    ORDER BY nombre_completo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ObtenerEmpleados_Entrevista` ()   BEGIN
    SELECT id_empleado, nombre_completo
    FROM empleados
    WHERE estado = 'activo'
    ORDER BY nombre_completo ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ObtenerExperiencia_Laboral` (IN `p_id_experiencia` INT)   BEGIN
    SELECT
        id_experiencia,
        id_oferente,
        nombre_empresa,
        puesto_desempenado,
        fecha_inicio,
        fecha_fin
    FROM experiencia_laboral
    WHERE id_experiencia = p_id_experiencia;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ObtenerNombreOferente` (IN `p_id_oferente` INT)   BEGIN
    SELECT p.nombre_comple AS NombreCompleto
    FROM oferentes o
    INNER JOIN personas p ON o.id_persona = p.id_persona
    WHERE o.id_oferente = p_id_oferente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ObtenerOferentesPorPuesto` (IN `pCodigoPuesto` VARCHAR(20))   BEGIN
    DECLARE vIdPuesto INT;
    DECLARE vTotalRequisitos INT;

    SELECT id_puesto INTO vIdPuesto
    FROM puestos
    WHERE codigo_puesto = pCodigoPuesto AND activo = 1
    LIMIT 1;

    SELECT COUNT(*) INTO vTotalRequisitos
    FROM requisitos_puesto
    WHERE id_puesto = vIdPuesto AND activo = 1;

    IF vTotalRequisitos = 0 THEN

        SELECT
            o.id_oferente,
            p.identificacion,
            p.nombre_comple AS nombre_completo
        FROM oferentes o
        INNER JOIN personas p ON o.id_persona = p.id_persona
        ORDER BY p.nombre_comple;

    ELSE

        SELECT
            o.id_oferente,
            p.identificacion,
            p.nombre_comple AS nombre_completo
        FROM oferentes o
        INNER JOIN personas p ON o.id_persona = p.id_persona
        INNER JOIN oferente_requisito orq ON orq.id_oferente = o.id_oferente
        INNER JOIN requisitos_puesto rp ON rp.id_requisito = orq.id_requisito
            AND rp.id_puesto = vIdPuesto
            AND rp.activo = 1
        GROUP BY o.id_oferente, p.identificacion, p.nombre_comple
        HAVING COUNT(DISTINCT orq.id_requisito) = vTotalRequisitos
        ORDER BY p.nombre_comple;

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ObtenerOferentes_Entrevista` ()   BEGIN
    SELECT o.id_oferente, p.nombre_comple AS nombre_completo
    FROM oferentes o
    INNER JOIN personas p ON o.id_persona = p.id_persona
    ORDER BY p.nombre_comple ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ObtenerPuesto` (IN `pIdPuesto` INT)   BEGIN

    SELECT *
    FROM Puestos
    WHERE id_puesto = pIdPuesto;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Obtener_Area` (IN `p_id_area` INT)   BEGIN
    SELECT
        a.id_area,
        a.codigo_area,
        a.nombre_area,
        a.id_empleado,
        e.nombre_completo AS nombre_empleado
    FROM admin_area a
    LEFT JOIN empleados e ON a.id_empleado = e.id_empleado
    WHERE a.id_area = p_id_area;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Obtener_Compania` (IN `p_id_compania` INT)   BEGIN
    SELECT
        id_compania,
        codigo_compania,
        nombre
    FROM companias
    WHERE id_compania = p_id_compania;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Obtener_Entrevista` (IN `p_id_entrevista` INT)   BEGIN
    SELECT
        e.id_entrevista,
        e.id_oferente,
        p.nombre_comple      AS nombre_oferente,
        e.id_empleado,
        emp.nombre_completo  AS nombre_empleado,
        e.fecha_entrevista,
        e.estado
    FROM entrevistas e
    INNER JOIN oferentes o   ON e.id_oferente = o.id_oferente
    INNER JOIN personas p    ON o.id_persona  = p.id_persona
    INNER JOIN empleados emp ON e.id_empleado = emp.id_empleado
    WHERE e.id_entrevista = p_id_entrevista;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_oferentes_actualizar` (IN `pIdOferente` INT, IN `pIdentificacion` VARCHAR(30), IN `pTipoIdentificacion` VARCHAR(20), IN `pNombreCompleto` VARCHAR(150), IN `pFechaNacimiento` DATE, IN `pCorreosJson` LONGTEXT, IN `pTelefonosJson` LONGTEXT, IN `pConcursosJson` LONGTEXT, IN `pIdUsuario` INT)   BEGIN
    DECLARE vIdPersona INT;
    DECLARE vIndex INT DEFAULT 0;
    DECLARE vTotal INT DEFAULT 0;
    DECLARE vCorreo VARCHAR(150);
    DECLARE vTelefono VARCHAR(20);
    DECLARE vIdConcursoItem INT;
    DECLARE vAnterior LONGTEXT;
    DECLARE vActual LONGTEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pIdOferente IS NULL OR pIdOferente <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El oferente es requerido.';
    END IF;

    SELECT id_persona
    INTO vIdPersona
    FROM Oferentes
    WHERE id_oferente = pIdOferente;

    IF vIdPersona IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El oferente no existe.';
    END IF;

    IF pIdentificacion IS NULL OR TRIM(pIdentificacion) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La identificacion es requerida.';
    END IF;

    IF pTipoIdentificacion IS NULL
       OR pTipoIdentificacion NOT IN ('CedulaIdentidad', 'DIMEX', 'Pasaporte') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El tipo de identificacion no es valido.';
    END IF;

    IF pNombreCompleto IS NULL OR TRIM(pNombreCompleto) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre completo es requerido.';
    END IF;

    IF pFechaNacimiento IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de nacimiento es requerida.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Personas
        WHERE identificacion = TRIM(pIdentificacion)
          AND id_persona <> vIdPersona
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El numero de identificacion ya existe.';
    END IF;

    IF pCorreosJson IS NULL OR JSON_VALID(pCorreosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La lista de correos debe ser JSON valido.';
    END IF;

    IF JSON_TYPE(JSON_EXTRACT(pCorreosJson, '$')) <> 'ARRAY'
       OR JSON_LENGTH(pCorreosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe indicar al menos un correo.';
    END IF;

    IF pTelefonosJson IS NULL OR JSON_VALID(pTelefonosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La lista de telefonos debe ser JSON valido.';
    END IF;

    IF JSON_TYPE(JSON_EXTRACT(pTelefonosJson, '$')) <> 'ARRAY'
       OR JSON_LENGTH(pTelefonosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe indicar al menos un telefono.';
    END IF;

    IF pConcursosJson IS NULL OR JSON_VALID(pConcursosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La lista de concursos debe ser JSON valido.';
    END IF;

    IF JSON_TYPE(JSON_EXTRACT(pConcursosJson, '$')) <> 'ARRAY'
       OR JSON_LENGTH(pConcursosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe indicar al menos un concurso.';
    END IF;

    SELECT JSON_OBJECT(
        'idOferente', o.id_oferente,
        'idPersona', p.id_persona,
        'identificacion', p.identificacion,
        'tipoIdentificacion', p.tipo_identificacion,
        'nombreCompleto', p.nombre_comple,
        'fechaNacimiento', p.fecha_naci,
        'correos', COALESCE((
            SELECT JSON_ARRAYAGG(oc.correo)
            FROM Oferente_correo oc
            WHERE oc.id_oferente = o.id_oferente
        ), JSON_ARRAY()),
        'telefonos', COALESCE((
            SELECT JSON_ARRAYAGG(ot.telefono)
            FROM Oferente_telf ot
            WHERE ot.id_oferente = o.id_oferente
        ), JSON_ARRAY()),
        'concursos', COALESCE((
            SELECT JSON_ARRAYAGG(ofc.id_concursos)
            FROM Oferente_concur ofc
            WHERE ofc.id_oferente = o.id_oferente
        ), JSON_ARRAY())
    )
    INTO vAnterior
    FROM Oferentes o
    INNER JOIN Personas p ON p.id_persona = o.id_persona
    WHERE o.id_oferente = pIdOferente;

    START TRANSACTION;

    UPDATE Personas
    SET
        identificacion = TRIM(pIdentificacion),
        tipo_identificacion = pTipoIdentificacion,
        nombre_comple = TRIM(pNombreCompleto),
        fecha_naci = pFechaNacimiento,
        tipo_perso = 'Oferente'
    WHERE id_persona = vIdPersona;

    DELETE FROM Oferente_correo
    WHERE id_oferente = pIdOferente;

    DELETE FROM Oferente_telf
    WHERE id_oferente = pIdOferente;

    DELETE FROM Oferente_concur
    WHERE id_oferente = pIdOferente;

    SET vIndex = 0;
    SET vTotal = JSON_LENGTH(pCorreosJson);
    WHILE vIndex < vTotal DO
        SET vCorreo = TRIM(JSON_UNQUOTE(JSON_EXTRACT(pCorreosJson, CONCAT('$[', vIndex, ']'))));

        IF vCorreo IS NULL OR vCorreo = '' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El correo es requerido.';
        END IF;

        IF vCorreo NOT REGEXP '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El correo no tiene un formato valido.';
        END IF;

        INSERT INTO Oferente_correo(id_oferente, correo)
        VALUES (pIdOferente, vCorreo);

        SET vIndex = vIndex + 1;
    END WHILE;

    SET vIndex = 0;
    SET vTotal = JSON_LENGTH(pTelefonosJson);
    WHILE vIndex < vTotal DO
        SET vTelefono = TRIM(JSON_UNQUOTE(JSON_EXTRACT(pTelefonosJson, CONCAT('$[', vIndex, ']'))));

        IF vTelefono IS NULL OR vTelefono = '' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El telefono es requerido.';
        END IF;

        INSERT INTO Oferente_telf(id_oferente, telefono)
        VALUES (pIdOferente, vTelefono);

        SET vIndex = vIndex + 1;
    END WHILE;

    SET vIndex = 0;
    SET vTotal = JSON_LENGTH(pConcursosJson);
    WHILE vIndex < vTotal DO
        SET vIdConcursoItem = CAST(JSON_UNQUOTE(JSON_EXTRACT(pConcursosJson, CONCAT('$[', vIndex, ']'))) AS UNSIGNED);

        IF vIdConcursoItem IS NULL OR vIdConcursoItem <= 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El concurso indicado no es valido.';
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM Concursos
            WHERE id_concursos = vIdConcursoItem
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Uno de los concursos indicados no existe.';
        END IF;

        IF EXISTS (
            SELECT 1
            FROM Oferente_concur
            WHERE id_oferente = pIdOferente
              AND id_concursos = vIdConcursoItem
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No se deben repetir concursos para el oferente.';
        END IF;

        INSERT INTO Oferente_concur(id_oferente, id_concursos)
        VALUES (pIdOferente, vIdConcursoItem);

        SET vIndex = vIndex + 1;
    END WHILE;

    SET vActual = JSON_OBJECT(
        'idOferente', pIdOferente,
        'idPersona', vIdPersona,
        'identificacion', TRIM(pIdentificacion),
        'tipoIdentificacion', pTipoIdentificacion,
        'nombreCompleto', TRIM(pNombreCompleto),
        'fechaNacimiento', pFechaNacimiento,
        'correos', JSON_EXTRACT(pCorreosJson, '$'),
        'telefonos', JSON_EXTRACT(pTelefonosJson, '$'),
        'concursos', JSON_EXTRACT(pConcursosJson, '$')
    );

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Actualizar OFE1',
        JSON_OBJECT(
            'mensaje', 'Se actualiza oferente',
            'anterior', JSON_EXTRACT(vAnterior, '$'),
            'actual', JSON_EXTRACT(vActual, '$')
        )
    );

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_oferentes_crear` (IN `pIdentificacion` VARCHAR(30), IN `pTipoIdentificacion` VARCHAR(20), IN `pNombreCompleto` VARCHAR(150), IN `pFechaNacimiento` DATE, IN `pCorreosJson` LONGTEXT, IN `pTelefonosJson` LONGTEXT, IN `pConcursosJson` LONGTEXT, IN `pIdUsuario` INT)   BEGIN
    DECLARE vIdPersona INT;
    DECLARE vIdOferente INT;
    DECLARE vIndex INT DEFAULT 0;
    DECLARE vTotal INT DEFAULT 0;
    DECLARE vCorreo VARCHAR(150);
    DECLARE vTelefono VARCHAR(20);
    DECLARE vIdConcursoItem INT;
    DECLARE vRegistro LONGTEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pIdentificacion IS NULL OR TRIM(pIdentificacion) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La identificacion es requerida.';
    END IF;

    IF pTipoIdentificacion IS NULL
       OR pTipoIdentificacion NOT IN ('CedulaIdentidad', 'DIMEX', 'Pasaporte') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El tipo de identificacion no es valido.';
    END IF;

    IF pNombreCompleto IS NULL OR TRIM(pNombreCompleto) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre completo es requerido.';
    END IF;

    IF pFechaNacimiento IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de nacimiento es requerida.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Personas
        WHERE identificacion = TRIM(pIdentificacion)
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El numero de identificacion ya existe.';
    END IF;

    IF pCorreosJson IS NULL OR JSON_VALID(pCorreosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La lista de correos debe ser JSON valido.';
    END IF;

    IF JSON_TYPE(JSON_EXTRACT(pCorreosJson, '$')) <> 'ARRAY'
       OR JSON_LENGTH(pCorreosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe indicar al menos un correo.';
    END IF;

    IF pTelefonosJson IS NULL OR JSON_VALID(pTelefonosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La lista de telefonos debe ser JSON valido.';
    END IF;

    IF JSON_TYPE(JSON_EXTRACT(pTelefonosJson, '$')) <> 'ARRAY'
       OR JSON_LENGTH(pTelefonosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe indicar al menos un telefono.';
    END IF;

    IF pConcursosJson IS NULL OR JSON_VALID(pConcursosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La lista de concursos debe ser JSON valido.';
    END IF;

    IF JSON_TYPE(JSON_EXTRACT(pConcursosJson, '$')) <> 'ARRAY'
       OR JSON_LENGTH(pConcursosJson) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe indicar al menos un concurso.';
    END IF;

    START TRANSACTION;

    INSERT INTO Personas(
        identificacion,
        tipo_identificacion,
        nombre_comple,
        fecha_naci,
        tipo_perso
    )
    VALUES (
        TRIM(pIdentificacion),
        pTipoIdentificacion,
        TRIM(pNombreCompleto),
        pFechaNacimiento,
        'Oferente'
    );

    SET vIdPersona = LAST_INSERT_ID();

    INSERT INTO Oferentes(id_persona)
    VALUES (vIdPersona);

    SET vIdOferente = LAST_INSERT_ID();

    SET vIndex = 0;
    SET vTotal = JSON_LENGTH(pCorreosJson);
    WHILE vIndex < vTotal DO
        SET vCorreo = TRIM(JSON_UNQUOTE(JSON_EXTRACT(pCorreosJson, CONCAT('$[', vIndex, ']'))));

        IF vCorreo IS NULL OR vCorreo = '' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El correo es requerido.';
        END IF;

        IF vCorreo NOT REGEXP '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El correo no tiene un formato valido.';
        END IF;

        INSERT INTO Oferente_correo(id_oferente, correo)
        VALUES (vIdOferente, vCorreo);

        SET vIndex = vIndex + 1;
    END WHILE;

    SET vIndex = 0;
    SET vTotal = JSON_LENGTH(pTelefonosJson);
    WHILE vIndex < vTotal DO
        SET vTelefono = TRIM(JSON_UNQUOTE(JSON_EXTRACT(pTelefonosJson, CONCAT('$[', vIndex, ']'))));

        IF vTelefono IS NULL OR vTelefono = '' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El telefono es requerido.';
        END IF;

        INSERT INTO Oferente_telf(id_oferente, telefono)
        VALUES (vIdOferente, vTelefono);

        SET vIndex = vIndex + 1;
    END WHILE;

    SET vIndex = 0;
    SET vTotal = JSON_LENGTH(pConcursosJson);
    WHILE vIndex < vTotal DO
        SET vIdConcursoItem = CAST(JSON_UNQUOTE(JSON_EXTRACT(pConcursosJson, CONCAT('$[', vIndex, ']'))) AS UNSIGNED);

        IF vIdConcursoItem IS NULL OR vIdConcursoItem <= 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El concurso indicado no es valido.';
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM Concursos
            WHERE id_concursos = vIdConcursoItem
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Uno de los concursos indicados no existe.';
        END IF;

        IF EXISTS (
            SELECT 1
            FROM Oferente_concur
            WHERE id_oferente = vIdOferente
              AND id_concursos = vIdConcursoItem
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No se deben repetir concursos para el oferente.';
        END IF;

        INSERT INTO Oferente_concur(id_oferente, id_concursos)
        VALUES (vIdOferente, vIdConcursoItem);

        SET vIndex = vIndex + 1;
    END WHILE;

    SET vRegistro = JSON_OBJECT(
        'idOferente', vIdOferente,
        'idPersona', vIdPersona,
        'identificacion', TRIM(pIdentificacion),
        'tipoIdentificacion', pTipoIdentificacion,
        'nombreCompleto', TRIM(pNombreCompleto),
        'fechaNacimiento', pFechaNacimiento,
        'correos', JSON_EXTRACT(pCorreosJson, '$'),
        'telefonos', JSON_EXTRACT(pTelefonosJson, '$'),
        'concursos', JSON_EXTRACT(pConcursosJson, '$')
    );

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Crear OFE1',
        JSON_OBJECT(
            'mensaje', 'Se crea oferente',
            'registro', JSON_EXTRACT(vRegistro, '$')
        )
    );

    COMMIT;

    SELECT vIdOferente AS IdOferente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_oferentes_eliminar` (IN `pIdOferente` INT, IN `pIdUsuario` INT)   BEGIN
    DECLARE vIdPersona INT;
    DECLARE vAnterior LONGTEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pIdOferente IS NULL OR pIdOferente <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El oferente es requerido.';
    END IF;

    SELECT id_persona
    INTO vIdPersona
    FROM oferentes
    WHERE id_oferente = pIdOferente;

    IF vIdPersona IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El oferente no existe.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM empleados
        WHERE id_oferente = pIdOferente
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar el oferente porque ya está asociado a un empleado.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM prepara_academica
        WHERE id_oferente = pIdOferente
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar un registro con datos relacionados.';
    END IF;

    SELECT JSON_OBJECT(
        'idOferente', o.id_oferente,
        'idPersona', p.id_persona,
        'identificacion', p.identificacion,
        'tipoIdentificacion', p.tipo_identificacion,
        'nombreCompleto', p.nombre_comple,
        'fechaNacimiento', p.fecha_naci,
        'correos', COALESCE((
            SELECT JSON_ARRAYAGG(oc.correo)
            FROM oferente_correo oc
            WHERE oc.id_oferente = o.id_oferente
        ), JSON_ARRAY()),
        'telefonos', COALESCE((
            SELECT JSON_ARRAYAGG(ot.telefono)
            FROM oferente_telf ot
            WHERE ot.id_oferente = o.id_oferente
        ), JSON_ARRAY()),
        'concursos', COALESCE((
            SELECT JSON_ARRAYAGG(ofc.id_concursos)
            FROM oferente_concur ofc
            WHERE ofc.id_oferente = o.id_oferente
        ), JSON_ARRAY())
    )
    INTO vAnterior
    FROM oferentes o
    INNER JOIN personas p ON p.id_persona = o.id_persona
    WHERE o.id_oferente = pIdOferente;

    START TRANSACTION;

    DELETE FROM oferente_concur
    WHERE id_oferente = pIdOferente;

    DELETE FROM oferente_correo
    WHERE id_oferente = pIdOferente;

    DELETE FROM oferente_telf
    WHERE id_oferente = pIdOferente;

    DELETE FROM oferentes
    WHERE id_oferente = pIdOferente;

    DELETE FROM personas
    WHERE id_persona = vIdPersona;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Eliminar OFE1',
        JSON_OBJECT(
            'mensaje', 'Se elimina oferente',
            'registroEliminado', JSON_EXTRACT(vAnterior, '$')
        )
    );

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_oferentes_listar` (IN `pPagina` INT, IN `pTamanoPagina` INT, IN `pIdUsuario` INT)   BEGIN
    DECLARE vPagina INT DEFAULT 1;
    DECLARE vTamanoPagina INT DEFAULT 10;
    DECLARE vOffset INT DEFAULT 0;

    SET vPagina = IFNULL(NULLIF(pPagina, 0), 1);
    SET vTamanoPagina = IFNULL(NULLIF(pTamanoPagina, 0), 10);

    IF vPagina < 1 THEN
        SET vPagina = 1;
    END IF;

    IF vTamanoPagina < 1 THEN
        SET vTamanoPagina = 10;
    END IF;

    SET vOffset = (vPagina - 1) * vTamanoPagina;

    SELECT
        o.id_oferente AS IdOferente,
        p.id_persona AS IdPersona,
        p.identificacion AS Identificacion,
        p.tipo_identificacion AS TipoIdentificacion,
        p.nombre_comple AS NombreCompleto,
        p.fecha_naci AS FechaNacimiento,
        o.fecha_regis AS FechaRegistro,
        COALESCE((
            SELECT JSON_ARRAYAGG(oc.correo)
            FROM Oferente_correo oc
            WHERE oc.id_oferente = o.id_oferente
        ), JSON_ARRAY()) AS Correos,
        COALESCE((
            SELECT JSON_ARRAYAGG(ot.telefono)
            FROM Oferente_telf ot
            WHERE ot.id_oferente = o.id_oferente
        ), JSON_ARRAY()) AS Telefonos,
        COALESCE((
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'idConcurso', c.id_concursos,
                    'codigo', c.codigo_concurso,
                    'nombre', c.nombre_concurso,
                    'estado', c.estado_concur
                )
            )
            FROM Oferente_concur ofc
            INNER JOIN Concursos c ON c.id_concursos = ofc.id_concursos
            WHERE ofc.id_oferente = o.id_oferente
        ), JSON_ARRAY()) AS Concursos
    FROM Oferentes o
    INNER JOIN Personas p ON p.id_persona = o.id_persona
    ORDER BY o.fecha_regis DESC, p.nombre_comple ASC
    LIMIT vTamanoPagina OFFSET vOffset;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Consultar OFE1',
        JSON_OBJECT(
            'mensaje', 'El usuario consulta oferentes',
            'pagina', vPagina,
            'tamanoPagina', vTamanoPagina
        )
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_oferentes_obtener` (IN `pIdOferente` INT, IN `pIdUsuario` INT)   BEGIN
    IF pIdOferente IS NULL OR pIdOferente <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El oferente es requerido.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Oferentes
        WHERE id_oferente = pIdOferente
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El oferente no existe.';
    END IF;

    SELECT
        o.id_oferente AS IdOferente,
        p.id_persona AS IdPersona,
        p.identificacion AS Identificacion,
        p.tipo_identificacion AS TipoIdentificacion,
        p.nombre_comple AS NombreCompleto,
        p.fecha_naci AS FechaNacimiento,
        o.fecha_regis AS FechaRegistro,
        COALESCE((
            SELECT JSON_ARRAYAGG(oc.correo)
            FROM Oferente_correo oc
            WHERE oc.id_oferente = o.id_oferente
        ), JSON_ARRAY()) AS Correos,
        COALESCE((
            SELECT JSON_ARRAYAGG(ot.telefono)
            FROM Oferente_telf ot
            WHERE ot.id_oferente = o.id_oferente
        ), JSON_ARRAY()) AS Telefonos,
        COALESCE((
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'idConcurso', c.id_concursos,
                    'codigo', c.codigo_concurso,
                    'nombre', c.nombre_concurso,
                    'estado', c.estado_concur
                )
            )
            FROM Oferente_concur ofc
            INNER JOIN Concursos c ON c.id_concursos = ofc.id_concursos
            WHERE ofc.id_oferente = o.id_oferente
        ), JSON_ARRAY()) AS Concursos
    FROM Oferentes o
    INNER JOIN Personas p ON p.id_persona = o.id_persona
    WHERE o.id_oferente = pIdOferente;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Consultar OFE1',
        JSON_OBJECT(
            'mensaje', 'El usuario consulta un oferente',
            'idOferente', pIdOferente
        )
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_PantallaRol_Asignar` (IN `p_idPantalla` INT, IN `p_idRol` INT)   BEGIN
    INSERT INTO rolpantalla(id_rol, id_pantalla)
    VALUES (p_idRol, p_idPantalla);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_PantallaRol_EliminarPorPantalla` (IN `p_idPantalla` INT)   BEGIN
    DELETE FROM rolpantalla
    WHERE id_pantalla = p_idPantalla;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_PantallaRol_ListarPorPantalla` (IN `p_idPantalla` INT)   BEGIN
    SELECT id_rol
    FROM rolpantalla
    WHERE id_pantalla = p_idPantalla;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Pantallas_Actualizar` (IN `p_idPantalla` INT, IN `p_nombrePantalla` VARCHAR(100))   BEGIN

    UPDATE Pantallas
    SET
        nombre_pantalla = p_nombrePantalla,
        fecha_modificacion = NOW()
    WHERE id_pantalla = p_idPantalla;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Pantallas_Crear` (IN `p_nombrePantalla` VARCHAR(100))   BEGIN

    INSERT INTO Pantallas
    (
        nombre_pantalla,
        activo
    )
    VALUES
    (
        p_nombrePantalla,
        1
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Pantallas_Eliminar` (IN `p_idPantalla` INT)   BEGIN

    DELETE FROM Pantallas
    WHERE id_pantalla = p_idPantalla;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Pantallas_Listar` ()   BEGIN

    SELECT *
    FROM Pantallas
    ORDER BY nombre_pantalla;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Pantallas_ListarPorRol` (IN `p_idRol` INT)   BEGIN
    SELECT p.nombre_pantalla
    FROM pantallas p
    INNER JOIN rolpantalla rp
        ON p.id_pantalla = rp.id_pantalla
    WHERE rp.id_rol = p_idRol
      AND p.activo = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Pantallas_ObtenerPorId` (IN `p_idPantalla` INT)   BEGIN

    SELECT *
    FROM Pantallas
    WHERE id_pantalla = p_idPantalla;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_preparacion_actualizar` (IN `pIdPreparacion` INT, IN `pIdInstitucion` INT, IN `pTitulo` VARCHAR(100), IN `pFechaInicio` DATE, IN `pFechaFin` DATE, IN `pIdUsuario` INT)   BEGIN
    DECLARE vAnterior LONGTEXT;
    DECLARE vActual LONGTEXT;
    DECLARE vIdOferente INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pIdPreparacion IS NULL OR pIdPreparacion <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La preparacion academica es requerida.';
    END IF;

    SELECT id_oferente
    INTO vIdOferente
    FROM prepara_academica
    WHERE id_pre_academica = pIdPreparacion;

    IF vIdOferente IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La preparacion academica no existe.';
    END IF;

    IF pIdInstitucion IS NULL OR pIdInstitucion <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La institucion educativa es requerida.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM institu_educa
        WHERE id_insti_edu = pIdInstitucion
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La institucion educativa no existe.';
    END IF;

    IF pTitulo IS NULL OR TRIM(pTitulo) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El titulo obtenido es requerido.';
    END IF;

    IF CHAR_LENGTH(TRIM(pTitulo)) > 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El titulo obtenido no puede superar 100 caracteres.';
    END IF;

    IF TRIM(pTitulo) NOT REGEXP '^[A-Za-zÁÉÍÓÚáéíóúÑñÜü ]+$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El titulo obtenido solo puede contener letras y espacios.';
    END IF;

    IF pFechaInicio IS NULL OR pFechaFin IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Las fechas de preparacion academica son requeridas.';
    END IF;

    IF pFechaFin < pFechaInicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de fin debe ser mayor o igual a la fecha de inicio.';
    END IF;

    SELECT JSON_OBJECT(
        'idPreparacion', id_pre_academica,
        'idOferente', id_oferente,
        'idInstitucion', id_insti_edu,
        'titulo', titulo_obtenido,
        'fechaInicio', fecha_inicio,
        'fechaFin', fecha_fin
    )
    INTO vAnterior
    FROM prepara_academica
    WHERE id_pre_academica = pIdPreparacion;

    START TRANSACTION;

    UPDATE prepara_academica
    SET
        id_insti_edu = pIdInstitucion,
        titulo_obtenido = TRIM(pTitulo),
        fecha_inicio = pFechaInicio,
        fecha_fin = pFechaFin
    WHERE id_pre_academica = pIdPreparacion;

    SET vActual = JSON_OBJECT(
        'idPreparacion', pIdPreparacion,
        'idOferente', vIdOferente,
        'idInstitucion', pIdInstitucion,
        'titulo', TRIM(pTitulo),
        'fechaInicio', pFechaInicio,
        'fechaFin', pFechaFin
    );

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Actualizar OFE3',
        JSON_OBJECT(
            'mensaje', 'Se actualiza preparacion academica',
            'anterior', JSON_EXTRACT(vAnterior, '$'),
            'actual', JSON_EXTRACT(vActual, '$')
        )
    );

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_preparacion_crear` (IN `pIdOferente` INT, IN `pIdInstitucion` INT, IN `pTitulo` VARCHAR(100), IN `pFechaInicio` DATE, IN `pFechaFin` DATE, IN `pIdUsuario` INT)   BEGIN
    DECLARE vIdPreparacion INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pIdOferente IS NULL OR pIdOferente <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El oferente es requerido.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM oferentes
        WHERE id_oferente = pIdOferente
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El oferente no existe.';
    END IF;

    IF pIdInstitucion IS NULL OR pIdInstitucion <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La institucion educativa es requerida.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM institu_educa
        WHERE id_insti_edu = pIdInstitucion
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La institucion educativa no existe.';
    END IF;

    IF pTitulo IS NULL OR TRIM(pTitulo) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El titulo obtenido es requerido.';
    END IF;

    IF CHAR_LENGTH(TRIM(pTitulo)) > 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El titulo obtenido no puede superar 100 caracteres.';
    END IF;

    IF TRIM(pTitulo) NOT REGEXP '^[A-Za-zÁÉÍÓÚáéíóúÑñÜü ]+$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El titulo obtenido solo puede contener letras y espacios.';
    END IF;

    IF pFechaInicio IS NULL OR pFechaFin IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Las fechas de preparacion academica son requeridas.';
    END IF;

    IF pFechaFin < pFechaInicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de fin debe ser mayor o igual a la fecha de inicio.';
    END IF;

    START TRANSACTION;

    INSERT INTO prepara_academica(
        id_oferente,
        id_insti_edu,
        titulo_obtenido,
        fecha_inicio,
        fecha_fin
    )
    VALUES (
        pIdOferente,
        pIdInstitucion,
        TRIM(pTitulo),
        pFechaInicio,
        pFechaFin
    );

    SET vIdPreparacion = LAST_INSERT_ID();

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Crear OFE3',
        JSON_OBJECT(
            'mensaje', 'Se crea preparacion academica',
            'registro', JSON_OBJECT(
                'idPreparacion', vIdPreparacion,
                'idOferente', pIdOferente,
                'idInstitucion', pIdInstitucion,
                'titulo', TRIM(pTitulo),
                'fechaInicio', pFechaInicio,
                'fechaFin', pFechaFin
            )
        )
    );

    COMMIT;

    SELECT vIdPreparacion AS IdPreparacion;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_preparacion_eliminar` (IN `pIdPreparacion` INT, IN `pIdUsuario` INT)   BEGIN
    DECLARE vAnterior LONGTEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF pIdPreparacion IS NULL OR pIdPreparacion <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La preparacion academica es requerida.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Prepara_academica
        WHERE id_pre_academica = pIdPreparacion
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La preparacion academica no existe.';
    END IF;

    SELECT JSON_OBJECT(
        'idPreparacion', id_pre_academica,
        'idOferente', id_oferente,
        'idInstitucion', id_insti_edu,
        'titulo', titulo_obtenido,
        'fechaInicio', fecha_inicio,
        'fechaFin', fecha_fin
    )
    INTO vAnterior
    FROM Prepara_academica
    WHERE id_pre_academica = pIdPreparacion;

    START TRANSACTION;

    DELETE FROM Prepara_academica
    WHERE id_pre_academica = pIdPreparacion;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Eliminar OFE3',
        JSON_OBJECT(
            'mensaje', 'Se elimina preparacion academica',
            'registroEliminado', JSON_EXTRACT(vAnterior, '$')
        )
    );

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_preparacion_listar_por_oferente` (IN `pIdOferente` INT, IN `pPagina` INT, IN `pTamanoPagina` INT, IN `pIdUsuario` INT)   BEGIN
    DECLARE vPagina INT DEFAULT 1;
    DECLARE vTamanoPagina INT DEFAULT 10;
    DECLARE vOffset INT DEFAULT 0;

    IF pIdOferente IS NULL OR pIdOferente <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El oferente es requerido.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Oferentes
        WHERE id_oferente = pIdOferente
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El oferente no existe.';
    END IF;

    SET vPagina = IFNULL(NULLIF(pPagina, 0), 1);
    SET vTamanoPagina = IFNULL(NULLIF(pTamanoPagina, 0), 10);

    IF vPagina < 1 THEN
        SET vPagina = 1;
    END IF;

    IF vTamanoPagina < 1 THEN
        SET vTamanoPagina = 10;
    END IF;

    SET vOffset = (vPagina - 1) * vTamanoPagina;

    SELECT
        pa.id_pre_academica AS IdPreparacion,
        pa.id_oferente AS IdOferente,
        pa.id_insti_edu AS IdInstitucion,
        ie.codigo_insti AS CodigoInstitucion,
        ie.nombre AS NombreInstitucion,
        pa.titulo_obtenido AS Titulo,
        pa.fecha_inicio AS FechaInicio,
        pa.fecha_fin AS FechaFin
    FROM Prepara_academica pa
    INNER JOIN Institu_educa ie ON ie.id_insti_edu = pa.id_insti_edu
    WHERE pa.id_oferente = pIdOferente
    ORDER BY pa.fecha_inicio DESC, pa.titulo_obtenido ASC
    LIMIT vTamanoPagina OFFSET vOffset;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Consultar OFE3',
        JSON_OBJECT(
            'mensaje', 'El usuario consulta preparacion academica de un oferente',
            'idOferente', pIdOferente,
            'pagina', vPagina,
            'tamanoPagina', vTamanoPagina
        )
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_preparacion_obtener` (IN `pIdPreparacion` INT, IN `pIdUsuario` INT)   BEGIN
    IF pIdPreparacion IS NULL OR pIdPreparacion <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La preparacion academica es requerida.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Prepara_academica
        WHERE id_pre_academica = pIdPreparacion
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La preparacion academica no existe.';
    END IF;

    SELECT
        pa.id_pre_academica AS IdPreparacion,
        pa.id_oferente AS IdOferente,
        pa.id_insti_edu AS IdInstitucion,
        ie.codigo_insti AS CodigoInstitucion,
        ie.nombre AS NombreInstitucion,
        pa.titulo_obtenido AS Titulo,
        pa.fecha_inicio AS FechaInicio,
        pa.fecha_fin AS FechaFin
    FROM Prepara_academica pa
    INNER JOIN Institu_educa ie ON ie.id_insti_edu = pa.id_insti_edu
    WHERE pa.id_pre_academica = pIdPreparacion;

    INSERT INTO bitacoras(id_usuario, accion, descripcionAccion)
    VALUES (
        pIdUsuario,
        'Consultar OFE3',
        JSON_OBJECT(
            'mensaje', 'El usuario consulta una preparacion academica',
            'idPreparacion', pIdPreparacion
        )
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Roles_Actualizar` (IN `p_idRol` INT, IN `p_nombrePermiso` VARCHAR(40))   BEGIN

    UPDATE Roles
    SET nombre_permiso = p_nombrePermiso
    WHERE id_rol = p_idRol;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Roles_Crear` (IN `p_nombrePermiso` VARCHAR(40))   BEGIN

    INSERT INTO Roles
    (
        nombre_permiso
    )
    VALUES
    (
        p_nombrePermiso
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Roles_Eliminar` (IN `p_idRol` INT)   BEGIN

    DELETE FROM Roles
    WHERE id_rol = p_idRol;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Roles_Listar` ()   BEGIN

    SELECT
        id_rol,
        nombre_permiso
    FROM Roles
    ORDER BY nombre_permiso;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Roles_ObtenerPorId` (IN `p_idRol` INT)   BEGIN

    SELECT *
    FROM Roles
    WHERE id_rol = p_idRol;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_RolPantalla_Asignar` (IN `p_idRol` INT, IN `p_idPantalla` INT)   BEGIN

    INSERT INTO RolPantalla
    (
        id_rol,
        id_pantalla
    )
    VALUES
    (
        p_idRol,
        p_idPantalla
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_RolPantalla_EliminarPorRol` (IN `p_idRol` INT)   BEGIN

    DELETE FROM RolPantalla
    WHERE id_rol = p_idRol;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_RolPantalla_ListarPorRol` (IN `p_idRol` INT)   BEGIN

    SELECT
        p.id_pantalla,
        p.nombre_pantalla
    FROM Pantallas p
    INNER JOIN RolPantalla rp
        ON p.id_pantalla = rp.id_pantalla
    WHERE rp.id_rol = p_idRol;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Usuarios_Actualizar` (IN `p_idUsuario` INT, IN `p_usuario` VARCHAR(50), IN `p_nombreCompleto` VARCHAR(150), IN `p_correo` VARCHAR(150), IN `p_idRol` INT)   BEGIN

    UPDATE Usuarios
    SET
        usuario = p_usuario,
        nombre_completo = p_nombreCompleto,
        correo = p_correo
    WHERE id_usuario = p_idUsuario;

    DELETE FROM UsuarioRol
    WHERE id_usuario = p_idUsuario;

    INSERT INTO UsuarioRol
    (
        id_usuario,
        id_rol
    )
    VALUES
    (
        p_idUsuario,
        p_idRol
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Usuarios_CambiarEstado` (IN `p_idUsuario` INT, IN `p_estado` VARCHAR(20))   BEGIN

    UPDATE Usuarios
    SET estado = p_estado
    WHERE id_usuario = p_idUsuario;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Usuarios_Crear` (IN `p_usuario` VARCHAR(50), IN `p_nombre_completo` VARCHAR(150), IN `p_correo` VARCHAR(150), IN `p_contrasena` VARCHAR(255), IN `p_estado` VARCHAR(20), IN `p_id_rol` INT)   BEGIN
    INSERT INTO Usuarios(
        usuario,
        nombre_completo,
        correo,
        contrasena,
        activo,
        estado,
        fecha_modifi,
        fecha_access
    )
    VALUES(
        p_usuario,
        p_nombre_completo,
        p_correo,
        p_contrasena,
        CASE WHEN p_estado = 'Activo' THEN 1 ELSE 0 END,
        p_estado,
        NOW(),
        NULL
    );

    INSERT INTO UsuarioRol(id_usuario, id_rol)
    VALUES(LAST_INSERT_ID(), p_id_rol);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Usuarios_Eliminar` (IN `p_idUsuario` INT)   BEGIN
    IF EXISTS (
        SELECT 1
        FROM UsuarioRol ur
        INNER JOIN RolPantalla rp 
            ON ur.id_rol = rp.id_rol
        WHERE ur.id_usuario = p_idUsuario
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar un registro con datos relacionados.';
    ELSE
        DELETE FROM UsuarioRol
        WHERE id_usuario = p_idUsuario;

        DELETE FROM Usuarios
        WHERE id_usuario = p_idUsuario;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Usuarios_Listar` ()   BEGIN
    SELECT
        u.id_usuario AS IdUsuario,
        u.usuario AS UsuarioNombre,
        u.nombre_completo AS NombreCompleto,
        u.correo AS Correo,
        u.estado AS Estado,
        CASE 
            WHEN u.estado = 'Activo' THEN 1 
            ELSE 0 
        END AS Activo,
        r.nombre_permiso AS NombrePermiso
    FROM Usuarios u
    LEFT JOIN UsuarioRol ur
        ON u.id_usuario = ur.id_usuario
    LEFT JOIN Roles r
        ON ur.id_rol = r.id_rol;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Usuarios_ObtenerPorId` (IN `p_idUsuario` INT)   BEGIN

    SELECT *
    FROM Usuarios
    WHERE id_usuario = p_idUsuario;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ValidarUsuario` (IN `pUsuario` VARCHAR(150))   BEGIN
    SELECT
        u.id_usuario AS IdUsuario,
        u.nombre_completo AS Usuario,
        u.contrasena AS PasswordCifrada,
        r.id_rol AS IdRol,
        u.intentos_fallidos,
        u.estado AS Estado,
        r.nombre_permiso AS NombreRol
    FROM Usuarios u
    INNER JOIN UsuarioRol ur ON u.id_usuario = ur.id_usuario
    INNER JOIN Roles r ON ur.id_rol = r.id_rol
    WHERE u.usuario = pUsuario
    LIMIT 1;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `accion_personal`
--

CREATE TABLE `accion_personal` (
  `id_accion` int(11) NOT NULL,
  `codigo_accion` varchar(20) DEFAULT NULL,
  `fecha_accion` date DEFAULT NULL,
  `descripcion` varchar(500) DEFAULT NULL,
  `id_empleado` int(11) DEFAULT NULL,
  `id_jefactura` int(11) DEFAULT NULL,
  `fecha_creacion` date DEFAULT NULL,
  `fehca_modificacion` date DEFAULT NULL,
  `activo` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `accion_personal`
--

INSERT INTO `accion_personal` (`id_accion`, `codigo_accion`, `fecha_accion`, `descripcion`, `id_empleado`, `id_jefactura`, `fecha_creacion`, `fehca_modificacion`, `activo`) VALUES
(1, 'CON-3', '2026-06-09', 'Contratación de empleado', 3, 2, '2026-06-09', NULL, 1),
(2, 'CON-4', '2026-06-09', 'Contratación de empleado', 4, 2, '2026-06-09', NULL, 1),
(3, 'CON-5', '2026-06-16', 'Contratación de empleado', 5, 1, '2026-06-16', NULL, 1),
(4, 'CON-6', '2026-06-16', 'Contratación de empleado', 6, 2, '2026-06-16', NULL, 1),
(5, 'CON-7', '2026-06-16', 'Contratación de empleado', 7, 3, '2026-06-16', NULL, 1),
(6, 'CON-8', '2026-06-30', 'Contratación de empleado', 8, 2, '2026-06-30', NULL, 1),
(7, 'ACC-1782871558', '2026-06-30', 'prueba', 7, 3, '2026-06-30', NULL, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `admin_area`
--

CREATE TABLE `admin_area` (
  `id_area` int(11) NOT NULL,
  `codigo_area` varchar(20) DEFAULT NULL,
  `nombre_area` varchar(100) DEFAULT NULL,
  `id_empleado` int(11) DEFAULT NULL,
  `activon` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `admin_area`
--

INSERT INTO `admin_area` (`id_area`, `codigo_area`, `nombre_area`, `id_empleado`, `activon`) VALUES
(1, 'RRHH-01', 'Recursos Humanos', 1, 1),
(4, 'FNC', 'Financiero', 3, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacoras`
--

CREATE TABLE `bitacoras` (
  `id_bitacoras` int(11) NOT NULL,
  `fecha_bitacora` datetime NOT NULL DEFAULT current_timestamp(),
  `id_usuario` int(11) NOT NULL,
  `accion` varchar(50) NOT NULL,
  `descripcionAccion` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`descripcionAccion`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `bitacoras`
--

INSERT INTO `bitacoras` (`id_bitacoras`, `fecha_bitacora`, `id_usuario`, `accion`, `descripcionAccion`) VALUES
(1, '2026-06-07 00:39:28', 1, 'se realizó la carga de información', '{\"tabla\": \"Provincia, Canton, Distrito\"}'),
(2, '2026-06-07 01:25:00', 1, 'se realizó la carga de información', '{\"tabla\": \"Provincia, Canton, Distrito\"}'),
(3, '2026-06-07 14:28:41', 1, 'CONSULTA', '{\"mensaje\": \"El usuario consulta compañías\"}'),
(4, '2026-06-07 14:28:42', 1, 'CONSULTA', '{\"mensaje\": \"El usuario consulta compañías\"}'),
(5, '2026-06-07 14:28:44', 1, 'CONSULTA', '{\"mensaje\": \"El usuario consulta compañías\"}'),
(6, '2026-06-07 17:26:29', 4, 'CONSULTA', '{\"mensaje\": \"El usuario consulta compañías\"}'),
(7, '2026-06-07 19:28:06', 4, 'CONSULTA', '{\"mensaje\": \"El usuario consulta compañías\"}'),
(8, '2026-06-07 20:54:00', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(9, '2026-06-07 20:54:00', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(10, '2026-06-07 20:54:01', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(11, '2026-06-07 20:54:02', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(12, '2026-06-07 20:54:04', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(13, '2026-06-07 20:54:05', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(14, '2026-06-07 20:54:05', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(15, '2026-06-07 20:54:06', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(16, '2026-06-07 20:54:07', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(17, '2026-06-07 20:54:07', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(18, '2026-06-07 20:54:07', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(19, '2026-06-07 20:54:08', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(20, '2026-06-07 20:54:09', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(21, '2026-06-07 20:54:10', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(22, '2026-06-07 20:54:11', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(23, '2026-06-07 20:54:14', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(24, '2026-06-07 20:54:16', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(25, '2026-06-07 20:54:23', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(26, '2026-06-07 20:54:24', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(27, '2026-06-07 22:41:11', 4, 'CONSULTA', '{\"mensaje\": \"El usuario consulta compañías\"}'),
(28, '2026-06-07 23:33:25', 4, 'CONSULTA', '{\"mensaje\": \"El usuario consulta compañías\"}'),
(29, '2026-06-07 23:33:28', 4, 'CONSULTA', '{\"mensaje\": \"El usuario consulta compañías\"}'),
(30, '2026-06-08 00:34:26', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(31, '2026-06-08 00:34:28', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(32, '2026-06-08 00:34:30', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(33, '2026-06-08 00:34:31', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(34, '2026-06-08 00:34:34', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(35, '2026-06-08 00:34:36', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(36, '2026-06-08 00:34:39', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(37, '2026-06-08 00:34:42', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(38, '2026-06-08 00:34:46', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(39, '2026-06-08 00:34:49', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(40, '2026-06-08 00:35:52', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(41, '2026-06-08 00:35:55', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(42, '2026-06-08 00:35:58', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(43, '2026-06-08 00:36:26', 7, 'INSERCION', '{\"tabla\": \"entrevistas\", \"registro\": {\"Estado\": \"Pendiente\", \"IdEmpleado\": 1, \"IdOferente\": 2, \"IdEntrevista\": 1, \"NombreEmpleado\": \"\", \"NombreOferente\": \"\", \"FechaEntrevista\": \"2026-06-17T15:00:00\"}}'),
(44, '2026-06-08 00:36:27', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(45, '2026-06-08 00:36:37', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(46, '2026-06-08 00:36:54', 7, 'INSERCION', '{\"tabla\": \"admin_area\", \"registro\": {\"IdArea\": 1, \"CodigoArea\": \"RRHH-01\", \"IdEmpleado\": 1, \"NombreArea\": \"Recursos Humanos\", \"NombreEmpleado\": \"\"}}'),
(47, '2026-06-08 00:36:54', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(48, '2026-06-08 00:36:58', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(49, '2026-06-08 00:37:02', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(50, '2026-06-08 00:37:05', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(51, '2026-06-08 00:37:11', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(52, '2026-06-08 00:37:12', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(53, '2026-06-08 00:37:13', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(54, '2026-06-08 00:37:14', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(55, '2026-06-08 00:37:54', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(56, '2026-06-08 02:11:14', 7, 'Consultar OFE1', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta oferentes\", \"tamanoPagina\": 10}'),
(57, '2026-06-08 02:11:19', 7, 'Consultar OFE2', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta concursos\", \"tamanoPagina\": 10}'),
(58, '2026-06-08 02:11:23', 7, 'Consultar OFE2', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta concursos\", \"tamanoPagina\": 10}'),
(59, '2026-06-08 02:11:24', 7, 'Consultar OFE2', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta concursos\", \"tamanoPagina\": 10}'),
(60, '2026-06-08 02:11:25', 7, 'Consultar OFE1', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta oferentes\", \"tamanoPagina\": 10}'),
(61, '2026-06-08 02:11:27', 7, 'Consultar OFE1', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta oferentes\", \"tamanoPagina\": 10}'),
(62, '2026-06-08 02:11:37', 7, 'Consultar OFE1', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta oferentes\", \"tamanoPagina\": 10}'),
(63, '2026-06-08 02:12:44', 7, 'Consultar OFE2', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta concursos\", \"tamanoPagina\": 10}'),
(64, '2026-06-08 02:13:13', 7, 'Consultar OFE1', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta oferentes\", \"tamanoPagina\": 10}'),
(65, '2026-06-08 02:13:30', 7, 'Consultar OFE2', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta concursos\", \"tamanoPagina\": 100}'),
(66, '2026-06-08 02:14:13', 7, 'Consultar OFE2', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta concursos\", \"tamanoPagina\": 100}'),
(67, '2026-06-08 02:14:16', 7, 'Consultar OFE2', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta concursos\", \"tamanoPagina\": 10}'),
(68, '2026-06-08 02:14:58', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"codigo\": \"CM-06\", \"estado\": \"Vigente\", \"nombre\": \"Medico General\", \"fechaFin\": \"2026-08-08\", \"idConcurso\": 1, \"fechaInicio\": \"2026-06-08\"}}'),
(69, '2026-06-08 02:14:58', 7, 'Consultar OFE2', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta concursos\", \"tamanoPagina\": 10}'),
(70, '2026-06-08 02:15:01', 7, 'Consultar OFE1', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta oferentes\", \"tamanoPagina\": 10}'),
(71, '2026-06-08 02:15:02', 7, 'Consultar OFE2', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta concursos\", \"tamanoPagina\": 100}'),
(72, '2026-06-08 02:15:05', 7, 'Consultar OFE1', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta oferentes\", \"tamanoPagina\": 10}'),
(73, '2026-06-08 02:15:09', 7, 'Consultar OFE2', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta concursos\", \"tamanoPagina\": 100}'),
(74, '2026-06-08 02:16:02', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"correos\": [\"jen@gmail.com\"], \"concursos\": [1], \"idPersona\": 3, \"telefonos\": [\"10101010\"], \"idOferente\": 3, \"identificacion\": \"305370931\", \"nombreCompleto\": \"Jenni Fuentes\", \"fechaNacimiento\": \"2002-03-12\", \"tipoIdentificacion\": \"CedulaIdentidad\"}}'),
(75, '2026-06-08 02:16:02', 7, 'Consultar OFE1', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta oferentes\", \"tamanoPagina\": 10}'),
(76, '2026-06-08 02:18:58', 7, 'Consultar OFE1', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta oferentes\", \"tamanoPagina\": 10}'),
(77, '2026-06-08 02:18:59', 7, 'Consultar OFE2', '{\"pagina\": 1, \"mensaje\": \"El usuario consulta concursos\", \"tamanoPagina\": 10}'),
(78, '2026-06-08 02:19:00', 7, 'CONSULTA', '{\"tabla\": \"entrevistas\", \"pagina\": 1}'),
(79, '2026-06-08 02:19:01', 7, 'CONSULTA', '{\"tabla\": \"admin_area\", \"pagina\": 1}'),
(80, '2026-06-08 22:25:52', 4, 'INSERTADO', '{\"tabla\": \"Parametros\"}'),
(81, '2026-06-08 22:26:37', 4, 'EDITADO', '{\"tabla\": \"Parametros\"}'),
(82, '2026-06-08 22:27:00', 4, 'INSERTADO', '{\"tabla\": \"Parametros\"}'),
(83, '2026-06-08 22:27:25', 4, 'INSERTADO', '{\"tabla\": \"Parametros\"}'),
(84, '2026-06-08 22:27:44', 4, 'INSERTADO', '{\"tabla\": \"Parametros\"}'),
(85, '2026-06-08 22:28:06', 4, 'INSERTADO', '{\"tabla\": \"Parametros\"}'),
(86, '2026-06-08 22:28:30', 4, 'INSERTADO', '{\"tabla\": \"Parametros\"}'),
(87, '2026-06-08 22:28:47', 4, 'INSERTADO', '{\"tabla\": \"Parametros\"}'),
(88, '2026-06-08 22:29:07', 4, 'INSERTADO', '{\"tabla\": \"Parametros\"}'),
(89, '2026-06-09 00:56:10', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(90, '2026-06-09 00:56:13', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(91, '2026-06-09 00:56:16', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(92, '2026-06-09 00:56:16', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(93, '2026-06-09 00:56:18', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(94, '2026-06-09 00:56:19', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(95, '2026-06-09 00:56:20', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(96, '2026-06-09 00:56:23', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(97, '2026-06-09 00:56:23', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(98, '2026-06-09 00:56:27', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(99, '2026-06-09 00:56:33', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(100, '2026-06-09 00:56:34', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(101, '2026-06-09 00:56:34', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(102, '2026-06-09 00:56:34', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(103, '2026-06-09 00:56:36', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(104, '2026-06-09 00:56:36', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(105, '2026-06-09 00:56:38', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(106, '2026-06-09 00:56:40', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(107, '2026-06-09 00:56:51', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(108, '2026-06-09 00:56:53', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(109, '2026-06-09 00:56:54', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(110, '2026-06-09 00:56:54', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(111, '2026-06-09 00:56:56', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(112, '2026-06-09 00:56:57', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(113, '2026-06-09 00:56:58', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(114, '2026-06-09 00:56:59', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(115, '2026-06-09 00:56:59', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(116, '2026-06-09 00:57:00', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(117, '2026-06-09 00:57:02', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(118, '2026-06-09 00:57:02', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(119, '2026-06-09 00:57:05', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(120, '2026-06-09 00:57:11', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(121, '2026-06-09 00:57:27', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(122, '2026-06-09 00:57:28', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(123, '2026-06-09 00:57:31', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(124, '2026-06-09 00:57:33', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(125, '2026-06-09 00:57:34', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(126, '2026-06-09 00:57:36', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(127, '2026-06-09 00:57:49', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(128, '2026-06-09 00:57:56', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(129, '2026-06-09 00:58:05', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(130, '2026-06-09 00:58:09', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(131, '2026-06-09 00:58:10', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(132, '2026-06-09 00:58:12', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(133, '2026-06-09 00:58:14', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(134, '2026-06-09 01:01:17', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(135, '2026-06-09 01:20:24', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(136, '2026-06-09 01:21:59', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(137, '2026-06-09 01:22:06', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(138, '2026-06-09 01:22:07', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(139, '2026-06-09 01:22:09', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(140, '2026-06-09 01:22:10', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(141, '2026-06-09 01:22:10', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(142, '2026-06-09 01:22:12', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(143, '2026-06-09 01:22:18', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(144, '2026-06-09 01:22:20', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(145, '2026-06-09 01:22:22', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(146, '2026-06-09 01:22:29', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(147, '2026-06-09 01:22:30', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(148, '2026-06-09 01:22:48', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(149, '2026-06-09 01:22:49', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(150, '2026-06-09 01:22:51', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(151, '2026-06-09 01:22:51', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(152, '2026-06-09 01:22:52', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(153, '2026-06-09 01:22:53', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(154, '2026-06-09 01:22:53', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(155, '2026-06-09 01:22:54', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(156, '2026-06-09 01:23:00', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(157, '2026-06-09 01:23:11', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(158, '2026-06-09 01:23:24', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(159, '2026-06-09 01:23:26', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(160, '2026-06-09 01:24:28', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(161, '2026-06-09 01:24:31', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(162, '2026-06-09 01:46:37', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(163, '2026-06-09 02:25:02', 4, 'EDITADO', '{\"tabla\":\"Parametros\"}'),
(164, '2026-06-09 02:25:17', 4, 'EDITADO', '{\"tabla\":\"Parametros\"}'),
(165, '2026-06-09 02:28:00', 4, 'se realizó la carga de información', '{\"tabla\":\"Provincia, Canton, Distrito\"}'),
(166, '2026-06-09 02:28:19', 4, 'se realizó la carga de información', '{\"tabla\":\"Provincia, Canton, Distrito\"}'),
(167, '2026-06-09 11:21:34', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(168, '2026-06-09 11:21:45', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(169, '2026-06-09 11:22:04', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(170, '2026-06-09 11:22:16', 7, 'Eliminar OFE1', '{\"mensaje\": \"Se elimina oferente\", \"registroEliminado\": {\"idOferente\": 3, \"idPersona\": 3, \"identificacion\": \"305370931\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Jenni Fuentes\", \"fechaNacimiento\": \"2002-03-12\", \"correos\": [\"jen@gmail.com\"], \"telefonos\": [\"10101010\"], \"concursos\": [1]}}'),
(171, '2026-06-09 11:22:16', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(172, '2026-06-09 11:22:19', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(173, '2026-06-09 11:22:22', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(174, '2026-06-09 11:22:24', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(175, '2026-06-09 11:22:40', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(176, '2026-06-09 11:24:01', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(177, '2026-06-09 11:24:42', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(178, '2026-06-09 11:24:43', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(179, '2026-06-09 11:28:03', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(180, '2026-06-09 12:10:04', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(181, '2026-06-09 12:10:09', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"1\", \"codigo\": \"UNA\", \"nombre\": \"Universidad Nacional de Costa Rica\"}}'),
(182, '2026-06-09 12:10:09', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(183, '2026-06-09 12:12:24', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"2\", \"codigo\": \"UCR\", \"nombre\": \"Universidad de Costa Rica\"}}'),
(184, '2026-06-09 12:12:24', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(185, '2026-06-09 12:12:30', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"3\", \"codigo\": \"CUC\", \"nombre\": \"Colegio Universitario Cartago\"}}'),
(186, '2026-06-09 12:12:30', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(187, '2026-06-09 12:13:42', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"4\", \"codigo\": \"INA\", \"nombre\": \"Instituto Nacional de Aprendizaje\"}}'),
(188, '2026-06-09 12:13:42', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(189, '2026-06-09 12:14:25', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"5\", \"codigo\": \"UTN\", \"nombre\": \"Universidad Tecnica Nacional\"}}'),
(190, '2026-06-09 12:14:25', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(191, '2026-06-09 12:18:43', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"5\"}'),
(192, '2026-06-09 12:18:46', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(193, '2026-06-09 12:23:22', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"5\"}'),
(194, '2026-06-09 12:23:27', 7, 'Actualizar GEN5', '{\"mensaje\": \"Se actualiza institucion educativa\", \"anterior\": {\"idInstitucion\": 5, \"codigo\": \"UTN\", \"nombre\": \"Universidad Tecnica Nacional\"}, \"actual\": {\"idInstitucion\": 5, \"codigo\": \"UTN\", \"nombre\": \"Universidad Técnica Nacional\"}}'),
(195, '2026-06-09 12:23:27', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(196, '2026-06-09 12:28:37', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(197, '2026-06-09 12:28:45', 7, 'Eliminar GEN5', '{\"mensaje\": \"Se elimina institucion educativa\", \"registroEliminado\": {\"idInstitucion\": 5, \"codigo\": \"UTN\", \"nombre\": \"Universidad Técnica Nacional\"}}'),
(198, '2026-06-09 12:28:45', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(199, '2026-06-09 12:28:53', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(200, '2026-06-09 12:29:01', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(201, '2026-06-09 12:29:23', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"6\", \"codigo\": \"UTN\", \"nombre\": \"Universidad Técnica Nacional\"}}'),
(202, '2026-06-09 12:29:23', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(203, '2026-06-09 12:29:46', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(204, '2026-06-09 12:29:51', 7, 'Eliminar OFE2', '{\"mensaje\": \"Se elimina concurso\", \"registroEliminado\": {\"idConcurso\": 1, \"codigo\": \"CM-06\", \"nombre\": \"Medico General\", \"fechaInicio\": \"2026-06-08\", \"fechaFin\": \"2026-08-08\", \"estado\": \"Vigente\"}}'),
(205, '2026-06-09 12:29:51', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(206, '2026-06-09 12:30:45', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(207, '2026-06-09 12:30:53', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"7\", \"codigo\": \"UNED\", \"nombre\": \"Universidad Estatal a Distancia\"}}'),
(208, '2026-06-09 12:30:53', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(209, '2026-06-09 12:31:06', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"8\", \"codigo\": \"UACA\", \"nombre\": \"Universidad Autónoma de Centro América\"}}'),
(210, '2026-06-09 12:31:06', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(211, '2026-06-09 12:31:19', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"9\", \"codigo\": \"ULACIT\", \"nombre\": \"Universidad Latinoamericana de Ciencia y Tecnología\"}}'),
(212, '2026-06-09 12:31:19', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(213, '2026-06-09 12:31:33', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"10\", \"codigo\": \"UAM\", \"nombre\": \"Universidad Americana\"}}'),
(214, '2026-06-09 12:31:33', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(215, '2026-06-09 12:31:45', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"11\", \"codigo\": \"UH\", \"nombre\": \"Universidad Hispanoamericana\"}}'),
(216, '2026-06-09 12:31:45', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(217, '2026-06-09 12:31:57', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(218, '2026-06-09 12:31:59', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(219, '2026-06-09 12:32:04', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"12\", \"codigo\": \"UIA\", \"nombre\": \"Universidad Internacional de las Américas\"}}'),
(220, '2026-06-09 12:32:04', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(221, '2026-06-09 12:32:24', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"13\", \"codigo\": \"UCART\", \"nombre\": \"Universidad Florencio del Castillo\"}}'),
(222, '2026-06-09 12:32:24', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(223, '2026-06-09 12:32:35', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"14\", \"codigo\": \"USJ\", \"nombre\": \"Universidad San José\"}}'),
(224, '2026-06-09 12:32:35', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(225, '2026-06-09 12:33:03', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"15\", \"codigo\": \"ULATINA\", \"nombre\": \"Universidad Latina de Costa Rica\"}}'),
(226, '2026-06-09 12:33:03', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(227, '2026-06-09 12:33:06', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(228, '2026-06-09 12:33:08', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(229, '2026-06-09 12:33:25', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"16\", \"codigo\": \"G\", \"nombre\": \"Ñ\"}}'),
(230, '2026-06-09 12:33:25', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(231, '2026-06-09 12:33:27', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(232, '2026-06-09 12:33:30', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(233, '2026-06-09 12:33:35', 7, 'Eliminar GEN5', '{\"mensaje\": \"Se elimina institucion educativa\", \"registroEliminado\": {\"idInstitucion\": 16, \"codigo\": \"G\", \"nombre\": \"Ñ\"}}'),
(234, '2026-06-09 12:33:35', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(235, '2026-06-09 12:34:43', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(236, '2026-06-09 12:35:42', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"2\", \"codigo\": \"CON-2026-001\", \"nombre\": \"Reclutamiento Administrativo\", \"fechaInicio\": \"2026-06-10\", \"fechaFin\": \"2026-07-10\", \"estado\": \"Vigente\"}}'),
(237, '2026-06-09 12:35:43', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(238, '2026-06-09 12:35:47', 7, 'Cambiar estado OFE2', '{\"mensaje\": \"Se cambia estado de concurso\", \"idConcurso\": \"2\", \"estadoAnterior\": \"Vigente\", \"estadoActual\": \"Vencido\"}'),
(239, '2026-06-09 12:35:47', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(240, '2026-06-09 12:35:48', 7, 'Cambiar estado OFE2', '{\"mensaje\": \"Se cambia estado de concurso\", \"idConcurso\": \"2\", \"estadoAnterior\": \"Vencido\", \"estadoActual\": \"Vigente\"}'),
(241, '2026-06-09 12:35:48', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(242, '2026-06-09 12:36:13', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"3\", \"codigo\": \"CON-2026-002\", \"nombre\": \"Reclutamiento Enfermería\", \"fechaInicio\": \"2026-01-07\", \"fechaFin\": \"2026-01-08\", \"estado\": \"Vigente\"}}'),
(243, '2026-06-09 12:36:14', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(244, '2026-06-09 12:38:50', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"4\", \"codigo\": \"CON-2026-003\", \"nombre\": \"Reclutamiento Asistente de Recursos Humanos\", \"fechaInicio\": \"2026-01-08\", \"fechaFin\": \"2026-02-08\", \"estado\": \"Vigente\"}}'),
(245, '2026-06-09 12:38:50', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(246, '2026-06-09 12:39:13', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"5\", \"codigo\": \"CON-2026-004\", \"nombre\": \"Reclutamiento Médico General\", \"fechaInicio\": \"2026-06-30\", \"fechaFin\": \"2026-07-30\", \"estado\": \"Vigente\"}}'),
(247, '2026-06-09 12:39:13', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(248, '2026-06-09 12:39:37', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"6\", \"codigo\": \"CON-2026-005\", \"nombre\": \"Reclutamiento Auxiliar Contable\", \"fechaInicio\": \"2026-06-03\", \"fechaFin\": \"2026-07-03\", \"estado\": \"Vigente\"}}'),
(249, '2026-06-09 12:39:37', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(250, '2026-06-09 12:40:13', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"7\", \"codigo\": \"CON-2026-006\", \"nombre\": \"Reclutamiento Técnico en Farmacia\", \"fechaInicio\": \"2026-06-04\", \"fechaFin\": \"2026-07-04\", \"estado\": \"Vigente\"}}'),
(251, '2026-06-09 12:40:13', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(252, '2026-06-09 12:40:33', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"8\", \"codigo\": \"CON-2026-007\", \"nombre\": \"Reclutamiento Recepcionista Médico\", \"fechaInicio\": \"2026-06-05\", \"fechaFin\": \"2026-08-05\", \"estado\": \"Vigente\"}}'),
(253, '2026-06-09 12:40:33', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(254, '2026-06-09 12:40:56', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"9\", \"codigo\": \"CON-2026-008\", \"nombre\": \"Reclutamiento Analista de Nómina\", \"fechaInicio\": \"2026-05-01\", \"fechaFin\": \"2026-06-01\", \"estado\": \"Vigente\"}}'),
(255, '2026-06-09 12:40:56', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(256, '2026-06-09 12:41:00', 7, 'Cambiar estado OFE2', '{\"mensaje\": \"Se cambia estado de concurso\", \"idConcurso\": \"9\", \"estadoAnterior\": \"Vigente\", \"estadoActual\": \"Vencido\"}'),
(257, '2026-06-09 12:41:00', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(258, '2026-06-09 12:41:37', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"10\", \"codigo\": \"CON-2026-009\", \"nombre\": \"Reclutamiento Terapeuta Físico\", \"fechaInicio\": \"2026-06-08\", \"fechaFin\": \"2026-07-08\", \"estado\": \"Vigente\"}}'),
(259, '2026-06-09 12:41:37', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(260, '2026-06-09 12:42:05', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"11\", \"codigo\": \"CON-2026-010\", \"nombre\": \"Reclutamiento Nutricionista\", \"fechaInicio\": \"2026-06-13\", \"fechaFin\": \"2026-07-13\", \"estado\": \"Vigente\"}}'),
(261, '2026-06-09 12:42:05', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(262, '2026-06-09 12:42:25', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"12\", \"codigo\": \"CON-2026-011\", \"nombre\": \"Reclutamiento Psicólogo Clínico\", \"fechaInicio\": \"2026-06-05\", \"fechaFin\": \"2026-07-05\", \"estado\": \"Vigente\"}}'),
(263, '2026-06-09 12:42:25', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(264, '2026-06-09 12:42:41', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"13\", \"codigo\": \"CON-2026-012\", \"nombre\": \"Reclutamiento Técnico de Laboratorio\", \"fechaInicio\": \"2026-06-05\", \"fechaFin\": \"2026-06-07\", \"estado\": \"Vigente\"}}'),
(265, '2026-06-09 12:42:41', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(266, '2026-06-09 12:43:01', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"14\", \"codigo\": \"CON-2026-013\", \"nombre\": \"Asistente de Pacientes\", \"fechaInicio\": \"2026-06-06\", \"fechaFin\": \"2026-06-07\", \"estado\": \"Vigente\"}}'),
(267, '2026-06-09 12:43:01', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(268, '2026-06-09 12:43:09', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(269, '2026-06-09 12:43:12', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(270, '2026-06-09 12:43:42', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(271, '2026-06-09 12:43:53', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(272, '2026-06-09 12:43:58', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(273, '2026-06-09 12:44:36', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"15\", \"codigo\": \"CON-2026-014\", \"nombre\": \"Reclutamiento Auxiliar de Limpieza\", \"fechaInicio\": \"2026-06-16\", \"fechaFin\": \"2026-07-16\", \"estado\": \"Vigente\"}}'),
(274, '2026-06-09 12:44:36', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(275, '2026-06-09 12:45:02', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(276, '2026-06-09 12:45:20', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(277, '2026-06-09 12:51:34', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(278, '2026-06-09 12:51:38', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(279, '2026-06-09 12:52:24', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(280, '2026-06-09 12:53:36', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"4\", \"idPersona\": \"4\", \"identificacion\": \"118760945\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Carlos Andres Mora Solano\", \"fechaNacimiento\": \"1998-12-04\", \"correos\": [\"carlos.mora@gmail.com\"], \"telefonos\": [\"88887777\"], \"concursos\": [5, 15]}}'),
(281, '2026-06-09 12:53:36', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(282, '2026-06-09 12:53:42', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(283, '2026-06-09 12:54:21', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"5\", \"idPersona\": \"5\", \"identificacion\": \"702340981\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Maria Fernanda Rojas Vargas\", \"fechaNacimiento\": \"1996-09-22\", \"correos\": [\"maria.rojas@hotmail.com\"], \"telefonos\": [\"87776666\"], \"concursos\": [5]}}'),
(284, '2026-06-09 12:54:21', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(285, '2026-06-09 12:54:25', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(286, '2026-06-09 12:55:16', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(287, '2026-06-09 12:55:21', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"6\", \"idPersona\": \"6\", \"identificacion\": \"A12345678\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Andres Felipe Castro Gomez\", \"fechaNacimiento\": \"1994-12-02\", \"correos\": [\"andres.castro@yahoo.com\"], \"telefonos\": [\"86665555\", \"86241512\"], \"concursos\": [2]}}'),
(288, '2026-06-09 12:55:21', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(289, '2026-06-09 12:55:24', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(290, '2026-06-09 12:56:19', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"7\", \"idPersona\": \"7\", \"identificacion\": \"155812345678\", \"tipoIdentificacion\": \"DIMEX\", \"nombreCompleto\": \"Daniela Sofia Hernandez Ruiz\", \"fechaNacimiento\": \"1999-03-11\", \"correos\": [\"daniela.hernandez@yahoo.com\", \"daniela.h2@gmail.com.com\"], \"telefonos\": [\"89998888\", \"86241512\"], \"concursos\": [11, 2, 10]}}'),
(291, '2026-06-09 12:56:19', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(292, '2026-06-09 12:56:25', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(293, '2026-06-09 12:56:57', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"8\", \"idPersona\": \"8\", \"identificacion\": \"304560789\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Valeria Jimenez Araya\", \"fechaNacimiento\": \"2000-05-26\", \"correos\": [\"valeria.jimenez@test.com\"], \"telefonos\": [\"84561234\"], \"concursos\": [3]}}'),
(294, '2026-06-09 12:56:57', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(295, '2026-06-09 12:56:59', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(296, '2026-06-09 12:58:22', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"9\", \"idPersona\": \"9\", \"identificacion\": \"205670432\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Luis Diego Porras Salazar\", \"fechaNacimiento\": \"1995-01-14\", \"correos\": [\"luis.porras@mail.com\"], \"telefonos\": [\"83334444\"], \"concursos\": [13]}}'),
(297, '2026-06-09 12:58:23', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(298, '2026-06-09 12:58:30', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(299, '2026-06-09 12:59:15', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(300, '2026-06-09 12:59:19', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"10\", \"idPersona\": \"10\", \"identificacion\": \"109870654\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Sofia Elena Vergara Mena\", \"fechaNacimiento\": \"1985-12-14\", \"correos\": [\"sofia.vergara@gmail.com\"], \"telefonos\": [\"82221111\"], \"concursos\": [13]}}'),
(301, '2026-06-09 12:59:19', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(302, '2026-06-09 12:59:24', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(303, '2026-06-09 12:59:57', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"11\", \"idPersona\": \"11\", \"identificacion\": \"B98765432\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Ricardo Antonio Lopez Marin\", \"fechaNacimiento\": \"1990-12-15\", \"correos\": [\"ricardo.lopez@test.com\"], \"telefonos\": [\"81112222\"], \"concursos\": [7]}}'),
(304, '2026-06-09 12:59:57', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(305, '2026-06-09 13:00:01', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(306, '2026-06-09 13:00:37', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"12\", \"idPersona\": \"12\", \"identificacion\": \"155898765432\", \"tipoIdentificacion\": \"DIMEX\", \"nombreCompleto\": \"Camila Andrea Soto Peña\", \"fechaNacimiento\": \"1998-10-28\", \"correos\": [\"camila.soto@test.com\"], \"telefonos\": [\"89990000\"], \"concursos\": [3]}}'),
(307, '2026-06-09 13:00:38', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(308, '2026-06-09 13:00:40', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(309, '2026-06-09 13:01:11', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"13\", \"idPersona\": \"13\", \"identificacion\": \"402780123\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Jose Pablo Chaves Rojas\", \"fechaNacimiento\": \"1998-11-12\", \"correos\": [\"jose.chaves@test.com\"], \"telefonos\": [\"87001122\"], \"concursos\": [14]}}'),
(310, '2026-06-09 13:01:11', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(311, '2026-06-09 13:01:13', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(312, '2026-06-09 13:01:15', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(313, '2026-06-09 13:01:56', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"14\", \"idPersona\": \"14\", \"identificacion\": \"603450987\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Natalia Fernanda Castro Mora\", \"fechaNacimiento\": \"1999-12-19\", \"correos\": [\"natalia.castro@test.com\"], \"telefonos\": [\"86003344\"], \"concursos\": [8, 9, 3]}}'),
(314, '2026-06-09 13:01:56', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(315, '2026-06-09 13:02:22', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"14\"}'),
(316, '2026-06-09 13:02:22', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}');
INSERT INTO `bitacoras` (`id_bitacoras`, `fecha_bitacora`, `id_usuario`, `accion`, `descripcionAccion`) VALUES
(317, '2026-06-09 13:02:25', 7, 'Actualizar OFE1', '{\"mensaje\": \"Se actualiza oferente\", \"anterior\": {\"idOferente\": 14, \"idPersona\": 14, \"identificacion\": \"603450987\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Natalia Fernanda Castro Mora\", \"fechaNacimiento\": \"1999-12-19\", \"correos\": [\"natalia.castro@test.com\"], \"telefonos\": [\"86003344\"], \"concursos\": [3, 8, 9]}, \"actual\": {\"idOferente\": \"14\", \"idPersona\": \"14\", \"identificacion\": \"603450987\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Natalia Fernanda Castro Mora\", \"fechaNacimiento\": \"1999-12-19\", \"correos\": [\"natalia.castro@test.com\"], \"telefonos\": [\"86003344\"], \"concursos\": [8, 3]}}'),
(318, '2026-06-09 13:02:26', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(319, '2026-06-09 13:04:31', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(320, '2026-06-09 13:05:10', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"15\", \"idPersona\": \"15\", \"identificacion\": \"C45678901\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Gabriel Esteban Rojas Vega\", \"fechaNacimiento\": \"1996-07-24\", \"correos\": [\"gabriel.rojas@hotmail.com\"], \"telefonos\": [\"85005566\"], \"concursos\": [9]}}'),
(321, '2026-06-09 13:05:10', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(322, '2026-06-09 13:05:12', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(323, '2026-06-09 13:05:14', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(324, '2026-06-09 13:06:17', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(325, '2026-06-09 13:06:17', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"15\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(326, '2026-06-09 13:06:25', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(327, '2026-06-09 13:06:26', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(328, '2026-06-09 13:06:41', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(329, '2026-06-09 13:06:41', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"15\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(330, '2026-06-09 13:06:42', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(331, '2026-06-09 13:06:48', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(332, '2026-06-09 13:06:48', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"15\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(333, '2026-06-09 13:06:50', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(334, '2026-06-09 13:06:50', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(335, '2026-06-09 13:07:21', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(336, '2026-06-09 13:07:21', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(337, '2026-06-09 13:09:37', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(338, '2026-06-09 13:09:37', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(339, '2026-06-09 13:10:49', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(340, '2026-06-09 13:10:49', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(341, '2026-06-09 13:10:49', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"1\", \"idOferente\": \"15\", \"idInstitucion\": \"4\", \"titulo\": \"Analisis de Nóminas\", \"fechaInicio\": \"2023-11-22\", \"fechaFin\": \"2026-06-08\"}}'),
(342, '2026-06-09 13:10:49', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(343, '2026-06-09 13:10:49', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"15\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(344, '2026-06-09 13:11:04', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(345, '2026-06-09 13:11:10', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(346, '2026-06-09 13:11:10', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"15\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(347, '2026-06-09 13:11:11', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(348, '2026-06-09 13:11:11', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(349, '2026-06-09 13:11:14', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(350, '2026-06-09 13:11:14', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"15\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(351, '2026-06-09 13:11:16', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(352, '2026-06-09 13:11:29', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"14\"}'),
(353, '2026-06-09 13:11:29', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"14\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(354, '2026-06-09 13:11:33', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"14\"}'),
(355, '2026-06-09 13:11:33', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(356, '2026-06-09 13:11:54', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"14\"}'),
(357, '2026-06-09 13:11:54', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(358, '2026-06-09 13:11:54', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"2\", \"idOferente\": \"14\", \"idInstitucion\": \"10\", \"titulo\": \"Reclutamiento Enfermería\", \"fechaInicio\": \"2025-01-08\", \"fechaFin\": \"2026-06-08\"}}'),
(359, '2026-06-09 13:11:54', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"14\"}'),
(360, '2026-06-09 13:11:54', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"14\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(361, '2026-06-09 13:11:55', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"14\"}'),
(362, '2026-06-09 13:11:55', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(363, '2026-06-09 13:12:26', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"14\"}'),
(364, '2026-06-09 13:12:26', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(365, '2026-06-09 13:12:26', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"3\", \"idOferente\": \"14\", \"idInstitucion\": \"8\", \"titulo\": \"Reclutamiento Recepcionista Médico\", \"fechaInicio\": \"2022-01-04\", \"fechaFin\": \"2024-01-04\"}}'),
(366, '2026-06-09 13:12:27', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"14\"}'),
(367, '2026-06-09 13:12:27', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"14\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(368, '2026-06-09 13:12:31', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(369, '2026-06-09 13:12:39', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"13\"}'),
(370, '2026-06-09 13:12:39', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"13\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(371, '2026-06-09 13:12:42', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"13\"}'),
(372, '2026-06-09 13:12:43', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(373, '2026-06-09 13:12:55', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"13\"}'),
(374, '2026-06-09 13:12:55', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(375, '2026-06-09 13:12:55', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"4\", \"idOferente\": \"13\", \"idInstitucion\": \"13\", \"titulo\": \"Asistente de Pacientes\", \"fechaInicio\": \"2021-01-01\", \"fechaFin\": \"2023-01-01\"}}'),
(376, '2026-06-09 13:12:55', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"13\"}'),
(377, '2026-06-09 13:12:55', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"13\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(378, '2026-06-09 13:12:57', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(379, '2026-06-09 13:13:09', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"12\"}'),
(380, '2026-06-09 13:13:09', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"12\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(381, '2026-06-09 13:13:11', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"12\"}'),
(382, '2026-06-09 13:13:11', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(383, '2026-06-09 13:13:32', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"12\"}'),
(384, '2026-06-09 13:13:32', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(385, '2026-06-09 13:13:32', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"5\", \"idOferente\": \"12\", \"idInstitucion\": \"14\", \"titulo\": \"Reclutamiento Enfermería\", \"fechaInicio\": \"2024-06-09\", \"fechaFin\": \"2026-06-09\"}}'),
(386, '2026-06-09 13:13:32', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"12\"}'),
(387, '2026-06-09 13:13:32', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"12\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(388, '2026-06-09 13:13:34', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(389, '2026-06-09 13:13:43', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"11\"}'),
(390, '2026-06-09 13:13:43', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"11\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(391, '2026-06-09 13:13:45', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"11\"}'),
(392, '2026-06-09 13:13:45', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(393, '2026-06-09 13:13:58', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"11\"}'),
(394, '2026-06-09 13:13:58', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(395, '2026-06-09 13:13:58', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"6\", \"idOferente\": \"11\", \"idInstitucion\": \"6\", \"titulo\": \"Reclutamiento Técnico en Farmacia\", \"fechaInicio\": \"2023-06-05\", \"fechaFin\": \"2026-06-05\"}}'),
(396, '2026-06-09 13:13:59', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"11\"}'),
(397, '2026-06-09 13:13:59', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"11\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(398, '2026-06-09 13:14:01', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(399, '2026-06-09 13:14:10', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"10\"}'),
(400, '2026-06-09 13:14:10', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"10\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(401, '2026-06-09 13:14:11', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"10\"}'),
(402, '2026-06-09 13:14:11', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(403, '2026-06-09 13:14:22', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"10\"}'),
(404, '2026-06-09 13:14:22', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(405, '2026-06-09 13:14:22', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"7\", \"idOferente\": \"10\", \"idInstitucion\": \"7\", \"titulo\": \"Reclutamiento Técnico de Laboratorio\", \"fechaInicio\": \"2023-02-01\", \"fechaFin\": \"2026-02-01\"}}'),
(406, '2026-06-09 13:14:23', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"10\"}'),
(407, '2026-06-09 13:14:23', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"10\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(408, '2026-06-09 13:14:25', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(409, '2026-06-09 13:14:37', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"9\"}'),
(410, '2026-06-09 13:14:37', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"9\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(411, '2026-06-09 13:14:38', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"9\"}'),
(412, '2026-06-09 13:14:38', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(413, '2026-06-09 13:14:53', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"9\"}'),
(414, '2026-06-09 13:14:53', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(415, '2026-06-09 13:14:53', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"8\", \"idOferente\": \"9\", \"idInstitucion\": \"2\", \"titulo\": \"Reclutamiento Técnico de Laboratorio\", \"fechaInicio\": \"2024-05-02\", \"fechaFin\": \"2024-05-02\"}}'),
(416, '2026-06-09 13:14:53', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"9\"}'),
(417, '2026-06-09 13:14:53', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"9\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(418, '2026-06-09 13:14:55', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(419, '2026-06-09 13:15:02', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"8\"}'),
(420, '2026-06-09 13:15:02', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"8\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(421, '2026-06-09 13:15:04', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"8\"}'),
(422, '2026-06-09 13:15:04', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(423, '2026-06-09 13:15:19', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"8\"}'),
(424, '2026-06-09 13:15:19', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(425, '2026-06-09 13:15:19', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"9\", \"idOferente\": \"8\", \"idInstitucion\": \"9\", \"titulo\": \"Reclutamiento Enfermería\", \"fechaInicio\": \"2020-02-01\", \"fechaFin\": \"2026-02-01\"}}'),
(426, '2026-06-09 13:15:19', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"8\"}'),
(427, '2026-06-09 13:15:19', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"8\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(428, '2026-06-09 13:15:21', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(429, '2026-06-09 13:15:29', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"7\"}'),
(430, '2026-06-09 13:15:29', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"7\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(431, '2026-06-09 13:15:30', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"7\"}'),
(432, '2026-06-09 13:15:30', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(433, '2026-06-09 13:15:47', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"7\"}'),
(434, '2026-06-09 13:15:47', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(435, '2026-06-09 13:15:47', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"10\", \"idOferente\": \"7\", \"idInstitucion\": \"3\", \"titulo\": \"Reclutamiento Administrativo\", \"fechaInicio\": \"2021-02-02\", \"fechaFin\": \"2023-02-02\"}}'),
(436, '2026-06-09 13:15:47', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"7\"}'),
(437, '2026-06-09 13:15:47', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"7\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(438, '2026-06-09 13:15:49', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"7\"}'),
(439, '2026-06-09 13:15:49', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(440, '2026-06-09 13:16:07', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"7\"}'),
(441, '2026-06-09 13:16:07', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(442, '2026-06-09 13:16:07', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"11\", \"idOferente\": \"7\", \"idInstitucion\": \"4\", \"titulo\": \"Reclutamiento Terapeuta Físico\", \"fechaInicio\": \"2022-02-05\", \"fechaFin\": \"2024-02-05\"}}'),
(443, '2026-06-09 13:16:07', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"7\"}'),
(444, '2026-06-09 13:16:07', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"7\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(445, '2026-06-09 13:16:08', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"7\"}'),
(446, '2026-06-09 13:16:08', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(447, '2026-06-09 13:16:24', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"7\"}'),
(448, '2026-06-09 13:16:24', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(449, '2026-06-09 13:16:24', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"12\", \"idOferente\": \"7\", \"idInstitucion\": \"15\", \"titulo\": \"Reclutamiento Nutricionista\", \"fechaInicio\": \"2025-02-20\", \"fechaFin\": \"2026-02-20\"}}'),
(450, '2026-06-09 13:16:24', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"7\"}'),
(451, '2026-06-09 13:16:24', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"7\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(452, '2026-06-09 13:16:33', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(453, '2026-06-09 13:16:43', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"6\"}'),
(454, '2026-06-09 13:16:43', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"6\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(455, '2026-06-09 13:16:45', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"6\"}'),
(456, '2026-06-09 13:16:45', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(457, '2026-06-09 13:17:29', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"6\"}'),
(458, '2026-06-09 13:17:29', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(459, '2026-06-09 13:17:29', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"13\", \"idOferente\": \"6\", \"idInstitucion\": \"1\", \"titulo\": \"Reclutamiento Administrativo\", \"fechaInicio\": \"2021-12-20\", \"fechaFin\": \"2024-12-20\"}}'),
(460, '2026-06-09 13:17:29', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"6\"}'),
(461, '2026-06-09 13:17:29', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"6\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(462, '2026-06-09 13:17:32', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(463, '2026-06-09 13:17:34', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(464, '2026-06-09 13:17:39', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"5\"}'),
(465, '2026-06-09 13:17:39', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"5\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(466, '2026-06-09 13:17:41', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(467, '2026-06-09 13:17:43', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(468, '2026-06-09 13:17:48', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"5\"}'),
(469, '2026-06-09 13:17:48', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"5\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(470, '2026-06-09 13:17:49', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"5\"}'),
(471, '2026-06-09 13:17:49', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(472, '2026-06-09 13:18:11', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"5\"}'),
(473, '2026-06-09 13:18:11', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(474, '2026-06-09 13:18:11', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"14\", \"idOferente\": \"5\", \"idInstitucion\": \"15\", \"titulo\": \"Reclutamiento Médico General\", \"fechaInicio\": \"2019-11-12\", \"fechaFin\": \"2026-11-12\"}}'),
(475, '2026-06-09 13:18:11', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"5\"}'),
(476, '2026-06-09 13:18:11', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"5\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(477, '2026-06-09 13:18:22', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(478, '2026-06-09 13:18:31', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(479, '2026-06-09 13:18:35', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(480, '2026-06-09 13:18:39', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(481, '2026-06-09 13:22:43', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(482, '2026-06-09 13:23:45', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"16\", \"idPersona\": \"16\", \"identificacion\": \"117260885\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Kenneth Prado Solano\", \"fechaNacimiento\": \"1998-11-12\", \"correos\": [\"kennethps1998@gmail.com\"], \"telefonos\": [\"60921812\"], \"concursos\": [10]}}'),
(483, '2026-06-09 13:23:46', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(484, '2026-06-09 13:24:36', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"16\"}'),
(485, '2026-06-09 13:24:36', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(486, '2026-06-09 13:24:44', 7, 'Actualizar OFE1', '{\"mensaje\": \"Se actualiza oferente\", \"anterior\": {\"idOferente\": 16, \"idPersona\": 16, \"identificacion\": \"117260885\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Kenneth Prado Solano\", \"fechaNacimiento\": \"1998-11-12\", \"correos\": [\"kennethps1998@gmail.com\"], \"telefonos\": [\"60921812\"], \"concursos\": [10]}, \"actual\": {\"idOferente\": \"16\", \"idPersona\": \"16\", \"identificacion\": \"117260885\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Kenneth EDITADO Solano\", \"fechaNacimiento\": \"1998-11-12\", \"correos\": [\"kennethps1998@gmail.com\"], \"telefonos\": [\"60921812\"], \"concursos\": [10]}}'),
(487, '2026-06-09 13:24:44', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(488, '2026-06-09 13:25:14', 7, 'Eliminar OFE1', '{\"mensaje\": \"Se elimina oferente\", \"registroEliminado\": {\"idOferente\": 16, \"idPersona\": 16, \"identificacion\": \"117260885\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Kenneth EDITADO Solano\", \"fechaNacimiento\": \"1998-11-12\", \"correos\": [\"kennethps1998@gmail.com\"], \"telefonos\": [\"60921812\"], \"concursos\": [10]}}'),
(489, '2026-06-09 13:25:14', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(490, '2026-06-09 13:25:33', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(491, '2026-06-09 13:25:33', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(492, '2026-06-09 13:25:41', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(493, '2026-06-09 13:26:03', 7, 'Actualizar OFE1', '{\"mensaje\": \"Se actualiza oferente\", \"anterior\": {\"idOferente\": 15, \"idPersona\": 15, \"identificacion\": \"C45678901\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Gabriel Esteban Rojas Vega\", \"fechaNacimiento\": \"1996-07-24\", \"correos\": [\"gabriel.rojas@hotmail.com\"], \"telefonos\": [\"85005566\"], \"concursos\": [9]}, \"actual\": {\"idOferente\": \"15\", \"idPersona\": \"15\", \"identificacion\": \"C45678901\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Gabriel Esteban Rojas Vega\", \"fechaNacimiento\": \"1996-07-24\", \"correos\": [\"gabriel.rojas@hotmail.com\"], \"telefonos\": [\"85005566\"], \"concursos\": [9]}}'),
(494, '2026-06-09 13:26:03', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(495, '2026-06-09 13:26:08', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(496, '2026-06-09 13:26:50', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(497, '2026-06-09 13:30:48', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(498, '2026-06-09 13:30:51', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(499, '2026-06-09 13:30:51', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(500, '2026-06-09 13:30:53', 7, 'Actualizar OFE1', '{\"mensaje\": \"Se actualiza oferente\", \"anterior\": {\"idOferente\": 15, \"idPersona\": 15, \"identificacion\": \"C45678901\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Gabriel Esteban Rojas Vega\", \"fechaNacimiento\": \"1996-07-24\", \"correos\": [\"gabriel.rojas@hotmail.com\"], \"telefonos\": [\"85005566\"], \"concursos\": [9]}, \"actual\": {\"idOferente\": \"15\", \"idPersona\": \"15\", \"identificacion\": \"C45678901\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Gabriel Esteban Rojas Vega\", \"fechaNacimiento\": \"1996-07-24\", \"correos\": [\"gabriel.rojas@hotmail.com\"], \"telefonos\": [\"85005566\"], \"concursos\": [9]}}'),
(501, '2026-06-09 13:30:53', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(502, '2026-06-09 13:32:11', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(503, '2026-06-09 13:32:37', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"17\", \"idPersona\": \"17\", \"identificacion\": \"115240112\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"prueba Guardar\", \"fechaNacimiento\": \"1998-11-12\", \"correos\": [\"Guardar@gmail.com\"], \"telefonos\": [\"60921821\"], \"concursos\": [3]}}'),
(504, '2026-06-09 13:32:37', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(505, '2026-06-09 13:36:26', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(506, '2026-06-09 13:41:17', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"16\", \"codigo\": \"CON-2026-015\", \"nombre\": \"PruebaVigente\", \"fechaInicio\": \"2026-10-30\", \"fechaFin\": \"2027-03-12\", \"estado\": \"Vigente\"}}'),
(507, '2026-06-09 13:41:17', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(508, '2026-06-09 13:42:39', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"17\", \"codigo\": \"CON-2026-016\", \"nombre\": \"Prueba CRUD\", \"fechaInicio\": \"2026-12-12\", \"fechaFin\": \"2027-12-12\", \"estado\": \"Vigente\"}}'),
(509, '2026-06-09 13:42:39', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(510, '2026-06-09 13:43:51', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta un concurso\", \"idConcurso\": \"17\"}'),
(511, '2026-06-09 13:44:01', 7, 'Actualizar OFE2', '{\"mensaje\": \"Se actualiza concurso\", \"anterior\": {\"idConcurso\": 17, \"codigo\": \"CON-2026-016\", \"nombre\": \"Prueba CRUD\", \"fechaInicio\": \"2026-12-12\", \"fechaFin\": \"2027-12-12\", \"estado\": \"Vigente\"}, \"actual\": {\"idConcurso\": 17, \"codigo\": \"CON-2026-016\", \"nombre\": \"Prueba CRUD EDITADO\", \"fechaInicio\": \"2026-12-12\", \"fechaFin\": \"2027-12-12\", \"estado\": \"Vigente\"}}'),
(512, '2026-06-09 13:44:01', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(513, '2026-06-09 13:44:19', 7, 'Eliminar OFE2', '{\"mensaje\": \"Se elimina concurso\", \"registroEliminado\": {\"idConcurso\": 17, \"codigo\": \"CON-2026-016\", \"nombre\": \"Prueba CRUD EDITADO\", \"fechaInicio\": \"2026-12-12\", \"fechaFin\": \"2027-12-12\", \"estado\": \"Vigente\"}}'),
(514, '2026-06-09 13:44:19', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(515, '2026-06-09 13:46:09', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(516, '2026-06-09 13:46:41', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"17\"}'),
(517, '2026-06-09 13:46:41', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"17\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(518, '2026-06-09 13:46:45', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(519, '2026-06-09 13:47:36', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(520, '2026-06-09 13:48:17', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(521, '2026-06-09 13:48:31', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(522, '2026-06-09 13:48:38', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"18\", \"idPersona\": \"18\", \"identificacion\": \"C45678902\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Prueba OFETres\", \"fechaNacimiento\": \"1990-11-12\", \"correos\": [\"OFE3@gmail.com\"], \"telefonos\": [\"21232125\"], \"concursos\": [5, 15]}}'),
(523, '2026-06-09 13:48:38', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(524, '2026-06-09 13:48:41', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(525, '2026-06-09 13:48:46', 7, 'Eliminar OFE2', '{\"mensaje\": \"Se elimina concurso\", \"registroEliminado\": {\"idConcurso\": 16, \"codigo\": \"CON-2026-015\", \"nombre\": \"PruebaVigente\", \"fechaInicio\": \"2026-10-30\", \"fechaFin\": \"2027-03-12\", \"estado\": \"Vigente\"}}'),
(526, '2026-06-09 13:48:46', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(527, '2026-06-09 13:48:48', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(528, '2026-06-09 13:48:53', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(529, '2026-06-09 13:49:15', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(530, '2026-06-09 13:49:15', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"18\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(531, '2026-06-09 13:51:40', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(532, '2026-06-09 13:51:40', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(533, '2026-06-09 13:53:21', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(534, '2026-06-09 13:53:21', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(535, '2026-06-09 13:53:46', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(536, '2026-06-09 13:53:46', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(537, '2026-06-09 13:53:46', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"15\", \"idOferente\": \"18\", \"idInstitucion\": \"3\", \"titulo\": \"Prueba OFE TRES\", \"fechaInicio\": \"2025-01-09\", \"fechaFin\": \"2026-01-09\"}}'),
(538, '2026-06-09 13:53:46', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(539, '2026-06-09 13:53:46', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"18\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(540, '2026-06-09 13:54:33', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta una preparacion academica\", \"idPreparacion\": \"15\"}'),
(541, '2026-06-09 13:54:33', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(542, '2026-06-09 13:54:33', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(543, '2026-06-09 13:54:43', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(544, '2026-06-09 13:54:43', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(545, '2026-06-09 13:54:43', 7, 'Actualizar OFE3', '{\"mensaje\": \"Se actualiza preparacion academica\", \"anterior\": {\"idPreparacion\": 15, \"idOferente\": 18, \"idInstitucion\": 3, \"titulo\": \"Prueba OFE TRES\", \"fechaInicio\": \"2025-01-09\", \"fechaFin\": \"2026-01-09\"}, \"actual\": {\"idPreparacion\": \"15\", \"idOferente\": \"18\", \"idInstitucion\": \"3\", \"titulo\": \"Prueba OFE TRES EDITADOOOOOOOOOOOOOO\", \"fechaInicio\": \"2025-01-09\", \"fechaFin\": \"2026-01-09\"}}'),
(546, '2026-06-09 13:54:43', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(547, '2026-06-09 13:54:43', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"18\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(548, '2026-06-09 13:54:58', 7, 'Eliminar OFE3', '{\"mensaje\": \"Se elimina preparacion academica\", \"registroEliminado\": {\"idPreparacion\": 15, \"idOferente\": 18, \"idInstitucion\": 3, \"titulo\": \"Prueba OFE TRES EDITADOOOOOOOOOOOOOO\", \"fechaInicio\": \"2025-01-09\", \"fechaFin\": \"2026-01-09\"}}'),
(549, '2026-06-09 13:54:58', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(550, '2026-06-09 13:54:58', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"18\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(551, '2026-06-09 13:56:42', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(552, '2026-06-09 13:57:46', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"17\", \"codigo\": \"15151551\", \"nombre\": \"Pruebaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\"}}'),
(553, '2026-06-09 13:57:46', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(554, '2026-06-09 13:58:00', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"10\"}'),
(555, '2026-06-09 13:58:03', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(556, '2026-06-09 13:58:05', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"17\"}'),
(557, '2026-06-09 13:59:00', 7, 'Actualizar GEN5', '{\"mensaje\": \"Se actualiza institucion educativa\", \"anterior\": {\"idInstitucion\": 17, \"codigo\": \"15151551\", \"nombre\": \"Pruebaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\"}, \"actual\": {\"idInstitucion\": 17, \"codigo\": \"CRUD\", \"nombre\": \"Create Read Update Delete\"}}'),
(558, '2026-06-09 13:59:00', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(559, '2026-06-09 13:59:41', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"3\"}'),
(560, '2026-06-09 13:59:43', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(561, '2026-06-09 13:59:45', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"17\"}'),
(562, '2026-06-09 13:59:54', 7, 'Actualizar GEN5', '{\"mensaje\": \"Se actualiza institucion educativa\", \"anterior\": {\"idInstitucion\": 17, \"codigo\": \"CRUD\", \"nombre\": \"Create Read Update Delete\"}, \"actual\": {\"idInstitucion\": 17, \"codigo\": \"CRUD EDITADO\", \"nombre\": \"Create Read Update Delete EDITADOOO\"}}'),
(563, '2026-06-09 13:59:54', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(564, '2026-06-09 14:00:07', 7, 'Eliminar GEN5', '{\"mensaje\": \"Se elimina institucion educativa\", \"registroEliminado\": {\"idInstitucion\": 17, \"codigo\": \"CRUD EDITADO\", \"nombre\": \"Create Read Update Delete EDITADOOO\"}}'),
(565, '2026-06-09 14:00:07', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(566, '2026-06-09 14:53:32', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(567, '2026-06-09 14:54:21', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":13,\"pagina\":1}'),
(568, '2026-06-09 14:55:51', 7, 'INSERCION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":1,\"IdOferente\":13,\"NombreEmpresa\":\"Cl\\u00EDnica Se\\u00F1ora de los \\u00C1ngeles\",\"PuestoDesempenado\":\"Asistente de pacientes\",\"FechaInicio\":\"2024-08-09T00:00:00\",\"FechaFin\":\"2026-05-09T00:00:00\"}}'),
(569, '2026-06-09 14:55:51', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":13,\"pagina\":1}'),
(570, '2026-06-09 14:56:04', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(571, '2026-06-09 14:56:06', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(572, '2026-06-09 14:56:11', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(573, '2026-06-09 14:56:13', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(574, '2026-06-09 14:56:17', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(575, '2026-06-09 14:56:25', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":13,\"pagina\":1}'),
(576, '2026-06-09 14:56:35', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(577, '2026-06-09 14:57:06', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":13,\"pagina\":1}'),
(578, '2026-06-09 14:58:55', 7, 'INSERCION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":2,\"IdOferente\":13,\"NombreEmpresa\":\"Hospital Universal\",\"PuestoDesempenado\":\"Pasant\\u00EDa\",\"FechaInicio\":\"2024-02-09T00:00:00\",\"FechaFin\":\"2024-05-09T00:00:00\"}}'),
(579, '2026-06-09 14:58:55', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":13,\"pagina\":1}'),
(580, '2026-06-09 15:01:08', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(581, '2026-06-09 15:02:25', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":18,\"pagina\":1}'),
(582, '2026-06-09 15:04:28', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":18,\"pagina\":1}'),
(583, '2026-06-09 15:04:30', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(584, '2026-06-09 15:04:32', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(585, '2026-06-09 15:04:32', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"18\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(586, '2026-06-09 15:04:33', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(587, '2026-06-09 15:04:40', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(588, '2026-06-09 15:04:40', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"18\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(589, '2026-06-09 15:04:41', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(590, '2026-06-09 15:04:41', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(591, '2026-06-09 15:04:49', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":18,\"pagina\":1}'),
(592, '2026-06-09 15:04:50', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(593, '2026-06-09 15:04:52', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":17,\"pagina\":1}'),
(594, '2026-06-09 15:04:55', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(595, '2026-06-09 15:04:59', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":13,\"pagina\":1}');
INSERT INTO `bitacoras` (`id_bitacoras`, `fecha_bitacora`, `id_usuario`, `accion`, `descripcionAccion`) VALUES
(596, '2026-06-09 15:06:06', 7, 'ACTUALIZACION', '{\"tabla\":\"experiencia_laboral\",\"antes\":{\"IdExperiencia\":1,\"IdOferente\":13,\"NombreEmpresa\":\"Cl\\u00EDnica Se\\u00F1ora de los \\u00C1ngeles\",\"PuestoDesempenado\":\"Asistente de pacientes\",\"FechaInicio\":\"2024-08-09T00:00:00\",\"FechaFin\":\"2026-05-09T00:00:00\"},\"despues\":{\"IdExperiencia\":1,\"IdOferente\":13,\"NombreEmpresa\":\"Cl\\u00EDnica Se\\u00F1ora de los \\u00C1ngeles\",\"PuestoDesempenado\":\"Asistente de pacientes\",\"FechaInicio\":\"2024-08-09T00:00:00\",\"FechaFin\":\"2026-05-15T00:00:00\"}}'),
(597, '2026-06-09 15:06:06', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":13,\"pagina\":1}'),
(598, '2026-06-09 15:06:57', 7, 'ELIMINACION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":2,\"IdOferente\":13,\"NombreEmpresa\":\"Hospital Universal\",\"PuestoDesempenado\":\"Pasant\\u00EDa\",\"FechaInicio\":\"2024-02-09T00:00:00\",\"FechaFin\":\"2024-05-09T00:00:00\"}}'),
(599, '2026-06-09 15:06:57', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":13,\"pagina\":1}'),
(600, '2026-06-09 15:21:23', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(601, '2026-06-09 15:25:09', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":2,\"IdOferente\":9,\"NombreOferente\":\"\",\"IdEmpleado\":1,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-06-09T18:00:00\",\"Estado\":\"Pendiente\"}}'),
(602, '2026-06-09 15:25:09', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(603, '2026-06-09 15:25:38', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":3,\"IdOferente\":8,\"NombreOferente\":\"\",\"IdEmpleado\":2,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-06-24T00:00:00\",\"Estado\":\"Pendiente\"}}'),
(604, '2026-06-09 15:25:38', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(605, '2026-06-09 15:26:06', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":4,\"IdOferente\":15,\"NombreOferente\":\"\",\"IdEmpleado\":2,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"0001-01-05T10:00:00\",\"Estado\":\"Pendiente\"}}'),
(606, '2026-06-09 15:26:06', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(607, '2026-06-09 15:26:14', 7, 'ACTUALIZACION', '{\"tabla\":\"entrevistas\",\"id_entrevista\":4,\"estado\":\"Realizada\"}'),
(608, '2026-06-09 15:26:14', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(609, '2026-06-09 15:27:15', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":5,\"IdOferente\":5,\"NombreOferente\":\"\",\"IdEmpleado\":1,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-07-01T13:00:00\",\"Estado\":\"Pendiente\"}}'),
(610, '2026-06-09 15:27:15', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(611, '2026-06-09 15:27:45', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":6,\"IdOferente\":7,\"NombreOferente\":\"\",\"IdEmpleado\":1,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-06-15T09:00:00\",\"Estado\":\"Pendiente\"}}'),
(612, '2026-06-09 15:27:45', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(613, '2026-06-09 15:28:06', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":7,\"IdOferente\":12,\"NombreOferente\":\"\",\"IdEmpleado\":2,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-07-01T15:00:00\",\"Estado\":\"Pendiente\"}}'),
(614, '2026-06-09 15:28:06', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(615, '2026-06-09 15:28:50', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":8,\"IdOferente\":11,\"NombreOferente\":\"\",\"IdEmpleado\":2,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-07-28T13:30:00\",\"Estado\":\"Pendiente\"}}'),
(616, '2026-06-09 15:28:50', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(617, '2026-06-09 15:29:18', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":9,\"IdOferente\":6,\"NombreOferente\":\"\",\"IdEmpleado\":1,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-06-26T07:15:00\",\"Estado\":\"Pendiente\"}}'),
(618, '2026-06-09 15:29:18', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(619, '2026-06-09 15:29:53', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":10,\"IdOferente\":4,\"NombreOferente\":\"\",\"IdEmpleado\":1,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-06-12T11:00:00\",\"Estado\":\"Pendiente\"}}'),
(620, '2026-06-09 15:29:53', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(621, '2026-06-09 15:30:10', 7, 'ACTUALIZACION', '{\"tabla\":\"entrevistas\",\"id_entrevista\":2,\"estado\":\"Realizada\"}'),
(622, '2026-06-09 15:30:10', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(623, '2026-06-09 15:31:01', 7, 'ELIMINACION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":4,\"IdOferente\":15,\"NombreOferente\":\"Gabriel Esteban Rojas Vega\",\"IdEmpleado\":2,\"NombreEmpleado\":\"Daniel Perez\",\"FechaEntrevista\":\"0001-01-05T10:00:00\",\"Estado\":\"Realizada\"}}'),
(624, '2026-06-09 15:31:01', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(625, '2026-06-09 15:35:40', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(626, '2026-06-09 15:35:58', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(627, '2026-06-09 15:36:00', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(628, '2026-06-09 15:36:19', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(629, '2026-06-09 15:37:31', 7, 'INSERCION', '{\"tabla\":\"admin_area\",\"registro\":{\"IdArea\":2,\"CodigoArea\":\"TI-01\",\"NombreArea\":\"Tecnolog\\u00EDas de la informaci\\u00F3n dfgdfgfdgdfgdgdfgdfgdfgdggddfdddfgfdgdfgfdgfdgfgfdgfgfgfgkjdhskiudsndc\",\"IdEmpleado\":2,\"NombreEmpleado\":\"\"}}'),
(630, '2026-06-09 15:37:31', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(631, '2026-06-09 15:38:46', 7, 'INSERCION', '{\"tabla\":\"admin_area\",\"registro\":{\"IdArea\":3,\"CodigoArea\":\"FI-03\",\"NombreArea\":\"Finazas\",\"IdEmpleado\":2,\"NombreEmpleado\":\"\"}}'),
(632, '2026-06-09 15:38:46', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(633, '2026-06-09 15:39:27', 7, 'ACTUALIZACION', '{\"tabla\":\"admin_area\",\"antes\":{\"IdArea\":2,\"CodigoArea\":\"TI-01\",\"NombreArea\":\"Tecnolog\\u00EDas de la informaci\\u00F3n dfgdfgfdgdfgdgdfgdfgdfgdggddfdddfgfdgdfgfdgfdgfgfdgfgfgfgkjdhskiudsndc\",\"IdEmpleado\":2,\"NombreEmpleado\":\"Daniel Perez\"},\"despues\":{\"IdArea\":2,\"CodigoArea\":\"TI-01\",\"NombreArea\":\"Tecnolog\\u00EDas de la informaci\\u00F3n\",\"IdEmpleado\":2,\"NombreEmpleado\":\"\"}}'),
(634, '2026-06-09 15:39:27', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(635, '2026-06-09 15:39:49', 7, 'ACTUALIZACION', '{\"tabla\":\"admin_area\",\"antes\":{\"IdArea\":3,\"CodigoArea\":\"FI-03\",\"NombreArea\":\"Finazas\",\"IdEmpleado\":2,\"NombreEmpleado\":\"Daniel Perez\"},\"despues\":{\"IdArea\":3,\"CodigoArea\":\"FI-03\",\"NombreArea\":\"Finanzas\",\"IdEmpleado\":2,\"NombreEmpleado\":\"\"}}'),
(636, '2026-06-09 15:39:49', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(637, '2026-06-09 15:39:57', 7, 'ELIMINACION', '{\"tabla\":\"admin_area\",\"registro\":{\"IdArea\":3,\"CodigoArea\":\"FI-03\",\"NombreArea\":\"Finanzas\",\"IdEmpleado\":2,\"NombreEmpleado\":\"Daniel Perez\"}}'),
(638, '2026-06-09 15:39:57', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(639, '2026-06-09 15:43:41', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(640, '2026-06-09 15:44:57', 4, 'INSERCION', '{\"nuevo\":{\"IdCompania\":0,\"CodigoCompania\":\"CP-012\",\"Nombre\":\"Bienes SAfgvdfgdfgfdgfrfgjdcfsdfsdhusifuweiuweieurfierfieurfeiufjdfdjnvnvmcxvmncvcnvcjnvdkfjgoijfeo9ife0riew\\u00270rewrfepwfoskfsdfdsdkjvjkfdnhvjkdfhdiofuj\"}}'),
(641, '2026-06-09 15:44:57', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(642, '2026-06-09 15:45:21', 4, 'INSERCION', '{\"nuevo\":{\"IdCompania\":0,\"CodigoCompania\":\"CP-01341\",\"Nombre\":\"Lagar\"}}'),
(643, '2026-06-09 15:45:21', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(644, '2026-06-09 15:47:26', 4, 'INSERCION', '{\"nuevo\":{\"IdCompania\":0,\"CodigoCompania\":\"TD-0101\",\"Nombre\":\"Instituto nacional de seguros\"}}'),
(645, '2026-06-09 15:47:27', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(646, '2026-06-09 15:47:59', 4, 'INSERCION', '{\"nuevo\":{\"IdCompania\":0,\"CodigoCompania\":\"AS-02\",\"Nombre\":\"ASSA Compa\\u00F1\\u00EDa de Seguros\"}}'),
(647, '2026-06-09 15:47:59', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(648, '2026-06-09 15:48:28', 4, 'INSERCION', '{\"nuevo\":{\"IdCompania\":0,\"CodigoCompania\":\"CS-03001\",\"Nombre\":\"CCSS \\u2013 Caja Costarricense de Seguro Social\"}}'),
(649, '2026-06-09 15:48:28', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(650, '2026-06-09 15:48:42', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(651, '2026-06-09 15:48:46', 4, 'ACTUALIZACION', '{\"antes\":{\"IdCompania\":1,\"CodigoCompania\":\"CP-012\",\"Nombre\":\"Bienes SAfgvdfgdfgfdgfrfgjdcfsdfsdhusifuweiuweieurfierfieurfeiufjdfdjnvnvmcxvmncvcnvcjnvdkfjgoijfeo9ife0riew\\u00270rewrfepwfoskfsdfdsdkjvjkfdnhvjkdfhdiofuj\"},\"despues\":{\"IdCompania\":1,\"CodigoCompania\":\"CP-012\",\"Nombre\":\"Bienes SA\"}}'),
(652, '2026-06-09 15:48:46', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(653, '2026-06-09 15:50:21', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(654, '2026-06-09 15:50:36', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(655, '2026-06-09 15:52:52', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(656, '2026-06-09 15:53:00', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(657, '2026-06-09 15:53:02', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(658, '2026-06-09 15:53:06', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(659, '2026-06-09 15:53:56', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(660, '2026-06-09 15:53:59', 4, 'ELIMINACION', '{\"eliminado\":{\"IdCompania\":2,\"CodigoCompania\":\"CP-01341\",\"Nombre\":\"Lagar\"}}'),
(661, '2026-06-09 15:53:59', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(662, '2026-06-09 15:54:53', 4, 'INSERCION', '{\"nuevo\":{\"IdCompania\":0,\"CodigoCompania\":\"LA-002\",\"Nombre\":\"Lagar\"}}'),
(663, '2026-06-09 15:54:53', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(664, '2026-06-09 15:56:21', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(665, '2026-06-09 15:56:32', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(666, '2026-06-09 15:57:36', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(667, '2026-06-09 15:57:36', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(668, '2026-06-09 15:57:48', 7, 'Actualizar OFE1', '{\"mensaje\": \"Se actualiza oferente\", \"anterior\": {\"idOferente\": 18, \"idPersona\": 18, \"identificacion\": \"C45678902\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Prueba OFETres\", \"fechaNacimiento\": \"1990-11-12\", \"correos\": [\"OFE3@gmail.com\"], \"telefonos\": [\"21232125\"], \"concursos\": [5, 15]}, \"actual\": {\"idOferente\": \"18\", \"idPersona\": \"18\", \"identificacion\": \"C45678902\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Prueba OFETres\", \"fechaNacimiento\": \"1990-11-12\", \"correos\": [\"OFE13@gmail.com\"], \"telefonos\": [\"21232125\"], \"concursos\": [5, 15]}}'),
(669, '2026-06-09 15:57:48', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(670, '2026-06-09 15:58:16', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(671, '2026-06-09 15:58:22', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(672, '2026-06-09 15:58:32', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(673, '2026-06-09 15:58:48', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(674, '2026-06-09 15:59:08', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(675, '2026-06-09 15:59:16', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(676, '2026-06-09 15:59:22', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(677, '2026-06-09 15:59:45', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(678, '2026-06-09 15:59:52', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(679, '2026-06-09 16:00:02', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"15\"}'),
(680, '2026-06-09 16:00:02', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(681, '2026-06-09 16:00:06', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(682, '2026-06-09 16:00:11', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(683, '2026-06-09 16:00:18', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(684, '2026-06-09 16:00:40', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(685, '2026-06-09 16:00:43', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(686, '2026-06-09 16:00:45', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(687, '2026-06-09 16:01:21', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(688, '2026-06-09 16:01:51', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(689, '2026-06-09 16:01:59', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(690, '2026-06-09 16:03:26', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(691, '2026-06-09 16:05:07', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(692, '2026-06-09 16:05:11', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(693, '2026-06-09 18:48:50', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(694, '2026-06-09 18:51:46', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(695, '2026-06-09 18:53:27', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(696, '2026-06-09 18:53:49', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(697, '2026-06-09 18:53:59', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"1\"}'),
(698, '2026-06-09 18:53:59', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"1\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(699, '2026-06-09 18:54:04', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"1\"}'),
(700, '2026-06-09 18:54:04', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(701, '2026-06-09 18:54:13', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"1\"}'),
(702, '2026-06-09 18:54:13', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"1\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(703, '2026-06-09 18:54:16', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(704, '2026-06-09 18:54:18', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(705, '2026-06-09 18:54:20', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(706, '2026-06-09 18:54:23', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(707, '2026-06-09 18:54:28', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(708, '2026-06-09 18:54:31', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(709, '2026-06-09 18:54:33', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(710, '2026-06-09 18:54:40', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(711, '2026-06-09 18:55:01', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(712, '2026-06-09 18:55:09', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(713, '2026-06-09 18:55:12', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(714, '2026-06-09 18:55:16', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(715, '2026-06-14 19:49:17', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(716, '2026-06-14 19:49:19', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(717, '2026-06-14 19:49:21', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(718, '2026-06-14 19:49:22', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(719, '2026-06-14 19:49:23', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(720, '2026-06-15 10:33:26', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(721, '2026-06-15 10:33:39', 7, 'Cambiar estado OFE2', '{\"mensaje\": \"Se cambia estado de concurso\", \"idConcurso\": \"15\", \"estadoAnterior\": \"Vigente\", \"estadoActual\": \"Vencido\"}'),
(722, '2026-06-15 10:33:40', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(723, '2026-06-16 07:02:37', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(724, '2026-06-16 07:02:44', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(725, '2026-06-16 07:03:02', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(726, '2026-06-16 07:03:05', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(727, '2026-06-16 07:03:14', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(728, '2026-06-16 07:03:21', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"18\"}'),
(729, '2026-06-16 07:03:21', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(730, '2026-06-16 07:03:28', 7, 'Actualizar OFE1', '{\"mensaje\": \"Se actualiza oferente\", \"anterior\": {\"idOferente\": 18, \"idPersona\": 18, \"identificacion\": \"C45678902\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Prueba OFETres\", \"fechaNacimiento\": \"1990-11-12\", \"correos\": [\"OFE13@gmail.com\"], \"telefonos\": [\"21232125\"], \"concursos\": [5, 15]}, \"actual\": {\"idOferente\": \"18\", \"idPersona\": \"18\", \"identificacion\": \"C45678902\", \"tipoIdentificacion\": \"Pasaporte\", \"nombreCompleto\": \"Prueba OFETres\", \"fechaNacimiento\": \"1990-11-13\", \"correos\": [\"OFE13@gmail.com\"], \"telefonos\": [\"21232125\"], \"concursos\": [5, 15]}}'),
(731, '2026-06-16 07:03:28', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(732, '2026-06-16 07:31:00', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(733, '2026-06-16 07:31:10', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":18,\"pagina\":1}'),
(734, '2026-06-16 07:31:16', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(735, '2026-06-16 07:31:21', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(736, '2026-06-16 07:31:49', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(737, '2026-06-16 07:32:21', 7, 'INSERCION', '{\"tabla\":\"admin_area\",\"registro\":{\"IdArea\":4,\"CodigoArea\":\"FN\",\"NombreArea\":\"Financiero\",\"IdEmpleado\":3,\"NombreEmpleado\":\"\"}}'),
(738, '2026-06-16 07:32:21', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(739, '2026-06-16 07:32:45', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(740, '2026-06-16 08:25:53', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(741, '2026-06-16 08:25:56', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(742, '2026-06-16 08:26:46', 7, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"19\", \"idPersona\": \"19\", \"identificacion\": \"114365432\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Julio Rosales\", \"fechaNacimiento\": \"1994-05-16\", \"correos\": [\"Jr@gmail.com\"], \"telefonos\": [\"89743532\"], \"concursos\": [10, 8]}}'),
(743, '2026-06-16 08:26:46', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(744, '2026-06-16 08:43:46', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(745, '2026-06-16 08:43:51', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(746, '2026-06-16 08:43:56', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(747, '2026-06-16 08:44:35', 7, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"18\", \"codigo\": \"CON-2026-027\", \"nombre\": \"Doctor Residente\", \"fechaInicio\": \"2026-06-16\", \"fechaFin\": \"2026-08-16\", \"estado\": \"Vigente\"}}'),
(748, '2026-06-16 08:44:35', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(749, '2026-06-16 08:44:41', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta un concurso\", \"idConcurso\": \"5\"}'),
(750, '2026-06-16 08:44:45', 7, 'Actualizar OFE2', '{\"mensaje\": \"Se actualiza concurso\", \"anterior\": {\"idConcurso\": 5, \"codigo\": \"CON-2026-004\", \"nombre\": \"Reclutamiento Médico General\", \"fechaInicio\": \"2026-06-30\", \"fechaFin\": \"2026-07-30\", \"estado\": \"Vigente\"}, \"actual\": {\"idConcurso\": 5, \"codigo\": \"CON-2026-004\", \"nombre\": \"Reclutamiento Médico General.\", \"fechaInicio\": \"2026-06-30\", \"fechaFin\": \"2026-07-30\", \"estado\": \"Vigente\"}}'),
(751, '2026-06-16 08:44:46', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(752, '2026-06-16 08:44:51', 7, 'Cambiar estado OFE2', '{\"mensaje\": \"Se cambia estado de concurso\", \"idConcurso\": \"5\", \"estadoAnterior\": \"Vigente\", \"estadoActual\": \"Vencido\"}'),
(753, '2026-06-16 08:44:51', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(754, '2026-06-16 08:44:56', 7, 'Cambiar estado OFE2', '{\"mensaje\": \"Se cambia estado de concurso\", \"idConcurso\": \"5\", \"estadoAnterior\": \"Vencido\", \"estadoActual\": \"Vigente\"}'),
(755, '2026-06-16 08:44:56', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(756, '2026-06-16 08:45:00', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(757, '2026-06-16 08:45:06', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(758, '2026-06-16 08:45:09', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"19\"}'),
(759, '2026-06-16 08:45:09', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"19\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(760, '2026-06-16 08:45:12', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"19\"}'),
(761, '2026-06-16 08:45:12', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(762, '2026-06-16 08:45:31', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"19\"}'),
(763, '2026-06-16 08:45:32', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(764, '2026-06-16 08:45:32', 7, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"16\", \"idOferente\": \"19\", \"idInstitucion\": \"2\", \"titulo\": \"Estudios Generales\", \"fechaInicio\": \"2022-06-16\", \"fechaFin\": \"2026-06-15\"}}'),
(765, '2026-06-16 08:45:32', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"19\"}'),
(766, '2026-06-16 08:45:32', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"19\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(767, '2026-06-16 08:45:36', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta una preparacion academica\", \"idPreparacion\": \"16\"}'),
(768, '2026-06-16 08:45:36', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"19\"}'),
(769, '2026-06-16 08:45:36', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(770, '2026-06-16 08:45:40', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"19\"}'),
(771, '2026-06-16 08:45:40', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(772, '2026-06-16 08:45:40', 7, 'Actualizar OFE3', '{\"mensaje\": \"Se actualiza preparacion academica\", \"anterior\": {\"idPreparacion\": 16, \"idOferente\": 19, \"idInstitucion\": 2, \"titulo\": \"Estudios Generales\", \"fechaInicio\": \"2022-06-16\", \"fechaFin\": \"2026-06-15\"}, \"actual\": {\"idPreparacion\": \"16\", \"idOferente\": \"19\", \"idInstitucion\": \"7\", \"titulo\": \"Estudios Generales\", \"fechaInicio\": \"2022-06-16\", \"fechaFin\": \"2026-06-15\"}}'),
(773, '2026-06-16 08:45:40', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"19\"}'),
(774, '2026-06-16 08:45:40', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"19\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(775, '2026-06-16 08:45:44', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(776, '2026-06-16 08:45:49', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(777, '2026-06-16 08:45:52', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"3\"}'),
(778, '2026-06-16 08:45:58', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(779, '2026-06-16 08:46:00', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"4\"}'),
(780, '2026-06-16 08:46:03', 7, 'Actualizar GEN5', '{\"mensaje\": \"Se actualiza institucion educativa\", \"anterior\": {\"idInstitucion\": 4, \"codigo\": \"INA\", \"nombre\": \"Instituto Nacional de Aprendizaje\"}, \"actual\": {\"idInstitucion\": 4, \"codigo\": \"INA\", \"nombre\": \"Instituto Nacional de Aprendizaj\"}}'),
(781, '2026-06-16 08:46:03', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(782, '2026-06-16 08:46:05', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"4\"}'),
(783, '2026-06-16 08:46:08', 7, 'Actualizar GEN5', '{\"mensaje\": \"Se actualiza institucion educativa\", \"anterior\": {\"idInstitucion\": 4, \"codigo\": \"INA\", \"nombre\": \"Instituto Nacional de Aprendizaj\"}, \"actual\": {\"idInstitucion\": 4, \"codigo\": \"INA\", \"nombre\": \"Instituto Nacional de Aprendizaje\"}}'),
(784, '2026-06-16 08:46:08', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(785, '2026-06-16 08:46:23', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"18\", \"codigo\": \"UTC\", \"nombre\": \"Universidad Técnica Central\"}}'),
(786, '2026-06-16 08:46:24', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(787, '2026-06-16 08:46:28', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(788, '2026-06-16 08:46:39', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(789, '2026-06-16 08:46:55', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(790, '2026-06-16 08:47:00', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(791, '2026-06-16 08:47:20', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(792, '2026-06-16 08:47:29', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(793, '2026-06-16 08:47:30', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(794, '2026-06-16 08:47:33', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"4\"}'),
(795, '2026-06-16 08:47:33', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"4\"}'),
(796, '2026-06-16 08:47:35', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(797, '2026-06-16 08:47:37', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(798, '2026-06-16 08:47:46', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(799, '2026-06-16 08:47:51', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(800, '2026-06-16 08:47:55', 7, 'ELIMINACION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":10,\"IdOferente\":4,\"NombreOferente\":\"Carlos Andres Mora Solano\",\"IdEmpleado\":1,\"NombreEmpleado\":\"Juan P\\u00E9rez Mora\",\"FechaEntrevista\":\"2026-06-12T11:00:00\",\"Estado\":\"Pendiente\"}}'),
(801, '2026-06-16 08:47:55', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(802, '2026-06-16 08:48:02', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(803, '2026-06-16 08:48:11', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(804, '2026-06-16 08:48:13', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(805, '2026-06-16 08:48:32', 7, 'ELIMINACION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":2,\"IdOferente\":9,\"NombreOferente\":\"Luis Diego Porras Salazar\",\"IdEmpleado\":1,\"NombreEmpleado\":\"Juan P\\u00E9rez Mora\",\"FechaEntrevista\":\"2026-06-09T18:00:00\",\"Estado\":\"Realizada\"}}'),
(806, '2026-06-16 08:48:32', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(807, '2026-06-16 08:48:41', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(808, '2026-06-16 08:48:58', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(809, '2026-06-16 08:49:02', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(810, '2026-06-16 08:49:15', 7, 'ELIMINACION', '{\"tabla\":\"admin_area\",\"registro\":{\"IdArea\":2,\"CodigoArea\":\"TI-01\",\"NombreArea\":\"Tecnolog\\u00EDas de la informaci\\u00F3n\",\"IdEmpleado\":2,\"NombreEmpleado\":\"Daniel Perez\"}}'),
(811, '2026-06-16 08:49:15', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(812, '2026-06-16 08:49:22', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(813, '2026-06-16 08:49:32', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(814, '2026-06-16 08:49:37', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(815, '2026-06-16 08:49:41', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"19\"}'),
(816, '2026-06-16 08:49:41', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"19\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(817, '2026-06-16 08:49:48', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(818, '2026-06-16 08:49:49', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(819, '2026-06-16 08:49:50', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(820, '2026-06-16 08:49:55', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(821, '2026-06-16 15:28:51', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(822, '2026-06-16 15:29:04', 7, 'Eliminar OFE1', '{\"mensaje\": \"Se elimina oferente\", \"registroEliminado\": {\"idOferente\": 17, \"idPersona\": 17, \"identificacion\": \"115240112\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"prueba Guardar\", \"fechaNacimiento\": \"1998-11-12\", \"correos\": [\"Guardar@gmail.com\"], \"telefonos\": [\"60921821\"], \"concursos\": [3]}}'),
(823, '2026-06-16 15:29:04', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(824, '2026-06-16 15:29:20', 7, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(825, '2026-06-16 15:29:27', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(826, '2026-06-16 19:07:46', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(827, '2026-06-16 19:07:49', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(828, '2026-06-16 19:08:48', 12, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"20\", \"idPersona\": \"20\", \"identificacion\": \"112545121\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Kenneth Prueba\", \"fechaNacimiento\": \"1997-11-12\", \"correos\": [\"kennethprueba@gmail.com\"], \"telefonos\": [\"60211214\"], \"concursos\": [5]}}'),
(829, '2026-06-16 19:08:49', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(830, '2026-06-16 19:08:56', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(831, '2026-06-16 19:09:41', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(832, '2026-06-16 19:10:09', 12, 'Crear OFE1', '{\"mensaje\": \"Se crea oferente\", \"registro\": {\"idOferente\": \"21\", \"idPersona\": \"21\", \"identificacion\": \"117260885\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"fdsfds\", \"fechaNacimiento\": \"1990-03-12\", \"correos\": [\"hola@gmail.com\"], \"telefonos\": [\"60211541\"], \"concursos\": [5]}}'),
(833, '2026-06-16 19:10:09', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(834, '2026-06-16 19:10:24', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(835, '2026-06-16 19:10:49', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(836, '2026-06-16 19:10:54', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(837, '2026-06-16 19:10:58', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"20\"}'),
(838, '2026-06-16 19:10:58', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(839, '2026-06-16 19:11:06', 12, 'Actualizar OFE1', '{\"mensaje\": \"Se actualiza oferente\", \"anterior\": {\"idOferente\": 20, \"idPersona\": 20, \"identificacion\": \"112545121\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Kenneth Prueba\", \"fechaNacimiento\": \"1997-11-12\", \"correos\": [\"kennethprueba@gmail.com\"], \"telefonos\": [\"60211214\"], \"concursos\": [5]}, \"actual\": {\"idOferente\": \"20\", \"idPersona\": \"20\", \"identificacion\": \"112545121\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Kenneth Prueba Editado\", \"fechaNacimiento\": \"1997-11-12\", \"correos\": [\"kennethprueba@gmail.com\"], \"telefonos\": [\"60211214\"], \"concursos\": [5]}}'),
(840, '2026-06-16 19:11:06', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(841, '2026-06-16 19:11:16', 12, 'Eliminar OFE1', '{\"mensaje\": \"Se elimina oferente\", \"registroEliminado\": {\"idOferente\": 21, \"idPersona\": 21, \"identificacion\": \"117260885\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"fdsfds\", \"fechaNacimiento\": \"1990-03-12\", \"correos\": [\"hola@gmail.com\"], \"telefonos\": [\"60211541\"], \"concursos\": [5]}}'),
(842, '2026-06-16 19:11:16', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(843, '2026-06-16 19:11:29', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"20\"}'),
(844, '2026-06-16 19:11:29', 12, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"20\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(845, '2026-06-16 19:11:34', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"20\"}'),
(846, '2026-06-16 19:11:34', 12, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(847, '2026-06-16 19:12:03', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"20\"}'),
(848, '2026-06-16 19:12:03', 12, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"100\"}'),
(849, '2026-06-16 19:12:03', 12, 'Crear OFE3', '{\"mensaje\": \"Se crea preparacion academica\", \"registro\": {\"idPreparacion\": \"17\", \"idOferente\": \"20\", \"idInstitucion\": \"3\", \"titulo\": \"Tecnologias de informacion\", \"fechaInicio\": \"2020-11-12\", \"fechaFin\": \"2024-11-12\"}}'),
(850, '2026-06-16 19:12:03', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"20\"}'),
(851, '2026-06-16 19:12:03', 12, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"20\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(852, '2026-06-16 19:12:11', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(853, '2026-06-16 19:12:24', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(854, '2026-06-16 19:12:34', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(855, '2026-06-16 19:12:59', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(856, '2026-06-16 19:13:37', 12, 'Crear OFE2', '{\"mensaje\": \"Se crea concurso\", \"registro\": {\"idConcurso\": \"19\", \"codigo\": \"CON-2026-048\", \"nombre\": \"Concurso de prueba\", \"fechaInicio\": \"2026-05-16\", \"fechaFin\": \"2026-07-16\", \"estado\": \"Vigente\"}}'),
(857, '2026-06-16 19:13:37', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(858, '2026-06-16 19:13:45', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(859, '2026-06-16 19:13:53', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta un concurso\", \"idConcurso\": \"19\"}'),
(860, '2026-06-16 19:14:02', 12, 'Actualizar OFE2', '{\"mensaje\": \"Se actualiza concurso\", \"anterior\": {\"idConcurso\": 19, \"codigo\": \"CON-2026-048\", \"nombre\": \"Concurso de prueba\", \"fechaInicio\": \"2026-05-16\", \"fechaFin\": \"2026-07-16\", \"estado\": \"Vigente\"}, \"actual\": {\"idConcurso\": 19, \"codigo\": \"CON-2026-048\", \"nombre\": \"Concurso de pruebaSS\", \"fechaInicio\": \"2026-05-16\", \"fechaFin\": \"2026-07-16\", \"estado\": \"Vigente\"}}'),
(861, '2026-06-16 19:14:02', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(862, '2026-06-16 19:14:06', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(863, '2026-06-16 19:14:12', 12, 'Cambiar estado OFE2', '{\"mensaje\": \"Se cambia estado de concurso\", \"idConcurso\": \"19\", \"estadoAnterior\": \"Vigente\", \"estadoActual\": \"Vencido\"}'),
(864, '2026-06-16 19:14:12', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(865, '2026-06-16 19:14:20', 12, 'Eliminar OFE2', '{\"mensaje\": \"Se elimina concurso\", \"registroEliminado\": {\"idConcurso\": 19, \"codigo\": \"CON-2026-048\", \"nombre\": \"Concurso de pruebaSS\", \"fechaInicio\": \"2026-05-16\", \"fechaFin\": \"2026-07-16\", \"estado\": \"Vencido\"}}'),
(866, '2026-06-16 19:14:20', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(867, '2026-06-16 19:14:27', 12, 'Cambiar estado OFE2', '{\"mensaje\": \"Se cambia estado de concurso\", \"idConcurso\": \"9\", \"estadoAnterior\": \"Vencido\", \"estadoActual\": \"Vigente\"}'),
(868, '2026-06-16 19:14:27', 12, 'Consultar OFE2', '{\"mensaje\": \"El usuario consulta concursos\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(869, '2026-06-16 19:16:33', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(870, '2026-06-16 19:16:54', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(871, '2026-06-16 19:32:38', 4, 'INSERTADO', '{\"tabla\":\"Parametros\"}'),
(872, '2026-06-16 19:47:07', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(873, '2026-06-16 19:47:11', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(874, '2026-06-16 19:48:01', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(875, '2026-06-16 19:48:04', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(876, '2026-06-16 19:48:21', 7, 'INSERCION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":3,\"IdOferente\":20,\"NombreEmpresa\":\"Kdkd\",\"PuestoDesempenado\":\"Kxkdn\",\"FechaInicio\":\"2026-06-09T00:00:00\",\"FechaFin\":\"2026-06-16T00:00:00\"}}'),
(877, '2026-06-16 19:48:21', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(878, '2026-06-16 19:48:33', 7, 'ACTUALIZACION', '{\"tabla\":\"experiencia_laboral\",\"antes\":{\"IdExperiencia\":3,\"IdOferente\":20,\"NombreEmpresa\":\"Kdkd\",\"PuestoDesempenado\":\"Kxkdn\",\"FechaInicio\":\"2026-06-09T00:00:00\",\"FechaFin\":\"2026-06-16T00:00:00\"},\"despues\":{\"IdExperiencia\":3,\"IdOferente\":20,\"NombreEmpresa\":\"Kdkd\",\"PuestoDesempenado\":\"Kxkdn\",\"FechaInicio\":\"2026-06-09T00:00:00\",\"FechaFin\":\"2026-06-30T00:00:00\"}}'),
(879, '2026-06-16 19:48:33', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(880, '2026-06-16 19:48:40', 7, 'ELIMINACION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":3,\"IdOferente\":20,\"NombreEmpresa\":\"Kdkd\",\"PuestoDesempenado\":\"Kxkdn\",\"FechaInicio\":\"2026-06-09T00:00:00\",\"FechaFin\":\"2026-06-30T00:00:00\"}}'),
(881, '2026-06-16 19:48:40', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(882, '2026-06-16 19:48:47', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(883, '2026-06-16 19:48:56', 7, 'ACTUALIZACION', '{\"tabla\":\"entrevistas\",\"id_entrevista\":8,\"estado\":\"Realizada\"}'),
(884, '2026-06-16 19:48:56', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(885, '2026-06-16 19:49:19', 7, 'ACTUALIZACION', '{\"tabla\":\"entrevistas\",\"antes\":{\"IdEntrevista\":6,\"IdOferente\":7,\"NombreOferente\":\"Daniela Sofia Hernandez Ruiz\",\"IdEmpleado\":1,\"NombreEmpleado\":\"Juan P\\u00E9rez Mora\",\"FechaEntrevista\":\"2026-06-15T09:00:00\",\"Estado\":\"Pendiente\"},\"despues\":{\"IdEntrevista\":6,\"IdOferente\":7,\"NombreOferente\":\"\",\"IdEmpleado\":1,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-06-17T09:00:00\",\"Estado\":\"Pendiente\"}}'),
(886, '2026-06-16 19:49:19', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(887, '2026-06-16 19:49:35', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(888, '2026-06-16 19:49:46', 7, 'ACTUALIZACION', '{\"tabla\":\"admin_area\",\"antes\":{\"IdArea\":4,\"CodigoArea\":\"FN\",\"NombreArea\":\"Financiero\",\"IdEmpleado\":3,\"NombreEmpleado\":\"Andres Felipe Castro Gomez\"},\"despues\":{\"IdArea\":4,\"CodigoArea\":\"FNC\",\"NombreArea\":\"Financiero\",\"IdEmpleado\":3,\"NombreEmpleado\":\"\"}}'),
(889, '2026-06-16 19:49:46', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(890, '2026-06-16 19:50:31', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(891, '2026-06-16 19:50:47', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(892, '2026-06-16 19:50:52', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}');
INSERT INTO `bitacoras` (`id_bitacoras`, `fecha_bitacora`, `id_usuario`, `accion`, `descripcionAccion`) VALUES
(893, '2026-06-16 19:51:07', 7, 'INSERCION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":4,\"IdOferente\":20,\"NombreEmpresa\":\"Jffjfb\",\"PuestoDesempenado\":\"Jxnd\",\"FechaInicio\":\"2026-06-02T00:00:00\",\"FechaFin\":\"2026-06-30T00:00:00\"}}'),
(894, '2026-06-16 19:51:07', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(895, '2026-06-16 19:51:11', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(896, '2026-06-16 19:51:13', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(897, '2026-06-16 19:51:19', 7, 'ACTUALIZACION', '{\"tabla\":\"experiencia_laboral\",\"antes\":{\"IdExperiencia\":4,\"IdOferente\":20,\"NombreEmpresa\":\"Jffjfb\",\"PuestoDesempenado\":\"Jxnd\",\"FechaInicio\":\"2026-06-02T00:00:00\",\"FechaFin\":\"2026-06-30T00:00:00\"},\"despues\":{\"IdExperiencia\":4,\"IdOferente\":20,\"NombreEmpresa\":\"Jffjfb\",\"PuestoDesempenado\":\"Jxnd11222\",\"FechaInicio\":\"2026-06-02T00:00:00\",\"FechaFin\":\"2026-06-30T00:00:00\"}}'),
(898, '2026-06-16 19:51:19', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(899, '2026-06-16 19:51:38', 7, 'INSERCION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":5,\"IdOferente\":20,\"NombreEmpresa\":\"Liiiiss\",\"PuestoDesempenado\":\"LIsixhdhd\",\"FechaInicio\":\"2026-06-14T00:00:00\",\"FechaFin\":\"2026-06-16T00:00:00\"}}'),
(900, '2026-06-16 19:51:38', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(901, '2026-06-16 19:51:45', 7, 'ELIMINACION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":5,\"IdOferente\":20,\"NombreEmpresa\":\"Liiiiss\",\"PuestoDesempenado\":\"LIsixhdhd\",\"FechaInicio\":\"2026-06-14T00:00:00\",\"FechaFin\":\"2026-06-16T00:00:00\"}}'),
(902, '2026-06-16 19:51:45', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(903, '2026-06-16 19:57:22', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(904, '2026-06-16 19:57:26', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"20\"}'),
(905, '2026-06-16 19:57:26', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"20\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(906, '2026-06-16 19:57:30', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(907, '2026-06-16 19:57:32', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(908, '2026-06-16 19:57:45', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(909, '2026-06-16 19:57:48', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":19,\"pagina\":1}'),
(910, '2026-06-16 20:17:53', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(911, '2026-06-16 20:17:59', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(912, '2026-06-16 20:18:18', 7, 'INSERCION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":6,\"IdOferente\":20,\"NombreEmpresa\":\"Mmvcg\",\"PuestoDesempenado\":\"Deygd\",\"FechaInicio\":\"2026-06-02T00:00:00\",\"FechaFin\":\"2026-06-25T00:00:00\"}}'),
(913, '2026-06-16 20:18:18', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(914, '2026-06-16 20:18:27', 7, 'ELIMINACION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":4,\"IdOferente\":20,\"NombreEmpresa\":\"Jffjfb\",\"PuestoDesempenado\":\"Jxnd11222\",\"FechaInicio\":\"2026-06-02T00:00:00\",\"FechaFin\":\"2026-06-30T00:00:00\"}}'),
(915, '2026-06-16 20:18:27', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(916, '2026-06-16 20:18:42', 7, 'ACTUALIZACION', '{\"tabla\":\"experiencia_laboral\",\"antes\":{\"IdExperiencia\":6,\"IdOferente\":20,\"NombreEmpresa\":\"Mmvcg\",\"PuestoDesempenado\":\"Deygd\",\"FechaInicio\":\"2026-06-02T00:00:00\",\"FechaFin\":\"2026-06-25T00:00:00\"},\"despues\":{\"IdExperiencia\":6,\"IdOferente\":20,\"NombreEmpresa\":\"Mmvcg12334\",\"PuestoDesempenado\":\"Deygd\",\"FechaInicio\":\"2026-06-02T00:00:00\",\"FechaFin\":\"2026-06-25T00:00:00\"}}'),
(917, '2026-06-16 20:18:42', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(918, '2026-06-16 20:18:47', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(919, '2026-06-16 20:18:53', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(920, '2026-06-16 20:37:02', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(921, '2026-06-16 20:37:05', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(922, '2026-06-16 20:37:17', 7, 'INSERCION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":7,\"IdOferente\":20,\"NombreEmpresa\":\"Hggh\",\"PuestoDesempenado\":\"Bjbuj\",\"FechaInicio\":\"2026-06-03T00:00:00\",\"FechaFin\":\"2026-06-16T00:00:00\"}}'),
(923, '2026-06-16 20:37:17', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(924, '2026-06-16 20:37:22', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(925, '2026-06-16 20:37:49', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(926, '2026-06-16 20:37:57', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(927, '2026-06-16 20:37:59', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"20\"}'),
(928, '2026-06-16 20:37:59', 12, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"20\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(929, '2026-06-16 20:38:01', 12, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(930, '2026-06-30 18:20:09', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(931, '2026-06-30 18:20:12', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(932, '2026-06-30 18:20:36', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(933, '2026-06-30 18:21:33', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"2\", \"tamanoPagina\": \"10\"}'),
(934, '2026-06-30 18:21:35', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(935, '2026-06-30 20:08:14', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(936, '2026-06-30 20:08:18', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(937, '2026-06-30 20:08:54', 7, 'INSERCION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":8,\"IdOferente\":20,\"NombreEmpresa\":\"kkbfkb\",\"PuestoDesempenado\":\"flkfk\",\"FechaInicio\":\"2026-06-30T00:00:00\",\"FechaFin\":\"2026-07-16T00:00:00\"}}'),
(938, '2026-06-30 20:08:54', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(939, '2026-06-30 20:09:32', 7, 'ELIMINACION', '{\"tabla\":\"experiencia_laboral\",\"registro\":{\"IdExperiencia\":8,\"IdOferente\":20,\"NombreEmpresa\":\"kkbfkb\",\"PuestoDesempenado\":\"flkfk\",\"FechaInicio\":\"2026-06-30T00:00:00\",\"FechaFin\":\"2026-07-16T00:00:00\"}}'),
(940, '2026-06-30 20:09:32', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(941, '2026-06-30 20:09:49', 7, 'ACTUALIZACION', '{\"tabla\":\"experiencia_laboral\",\"antes\":{\"IdExperiencia\":6,\"IdOferente\":20,\"NombreEmpresa\":\"Mmvcg12334\",\"PuestoDesempenado\":\"Deygd\",\"FechaInicio\":\"2026-06-02T00:00:00\",\"FechaFin\":\"2026-06-25T00:00:00\"},\"despues\":{\"IdExperiencia\":6,\"IdOferente\":20,\"NombreEmpresa\":\"Mmvcg12334\",\"PuestoDesempenado\":\"Deygd\",\"FechaInicio\":\"2026-06-02T00:00:00\",\"FechaFin\":\"2026-08-13T00:00:00\"}}'),
(942, '2026-06-30 20:09:49', 7, 'CONSULTA', '{\"tabla\":\"experiencia_laboral\",\"id_oferente\":20,\"pagina\":1}'),
(943, '2026-06-30 20:10:08', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(944, '2026-06-30 20:10:53', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":11,\"IdOferente\":12,\"NombreOferente\":\"\",\"IdEmpleado\":5,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-07-03T20:10:00\",\"Estado\":\"Pendiente\"}}'),
(945, '2026-06-30 20:10:53', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(946, '2026-06-30 20:11:18', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":12,\"IdOferente\":19,\"NombreOferente\":\"\",\"IdEmpleado\":4,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-07-10T02:16:00\",\"Estado\":\"Pendiente\"}}'),
(947, '2026-06-30 20:11:19', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(948, '2026-06-30 20:11:48', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":13,\"IdOferente\":13,\"NombreOferente\":\"\",\"IdEmpleado\":3,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-07-12T20:11:00\",\"Estado\":\"Pendiente\"}}'),
(949, '2026-06-30 20:11:48', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(950, '2026-06-30 20:12:06', 7, 'INSERCION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":14,\"IdOferente\":18,\"NombreOferente\":\"\",\"IdEmpleado\":7,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-07-15T20:12:00\",\"Estado\":\"Pendiente\"}}'),
(951, '2026-06-30 20:12:06', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(952, '2026-06-30 20:12:10', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":2}'),
(953, '2026-06-30 20:12:25', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(954, '2026-06-30 20:12:44', 7, 'ACTUALIZACION', '{\"tabla\":\"entrevistas\",\"antes\":{\"IdEntrevista\":14,\"IdOferente\":18,\"NombreOferente\":\"Prueba OFETres\",\"IdEmpleado\":7,\"NombreEmpleado\":\"Carlos Andres Mora Solano\",\"FechaEntrevista\":\"2026-07-15T20:12:00\",\"Estado\":\"Pendiente\"},\"despues\":{\"IdEntrevista\":14,\"IdOferente\":18,\"NombreOferente\":\"\",\"IdEmpleado\":7,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-07-30T20:12:00\",\"Estado\":\"Pendiente\"}}'),
(955, '2026-06-30 20:12:45', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(956, '2026-06-30 20:13:03', 7, 'ACTUALIZACION', '{\"tabla\":\"entrevistas\",\"antes\":{\"IdEntrevista\":13,\"IdOferente\":13,\"NombreOferente\":\"Jose Pablo Chaves Rojas\",\"IdEmpleado\":3,\"NombreEmpleado\":\"Andres Felipe Castro Gomez\",\"FechaEntrevista\":\"2026-07-12T20:11:00\",\"Estado\":\"Pendiente\"},\"despues\":{\"IdEntrevista\":13,\"IdOferente\":13,\"NombreOferente\":\"\",\"IdEmpleado\":7,\"NombreEmpleado\":\"\",\"FechaEntrevista\":\"2026-07-12T20:11:00\",\"Estado\":\"Pendiente\"}}'),
(957, '2026-06-30 20:13:03', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(958, '2026-06-30 20:13:13', 7, 'ACTUALIZACION', '{\"tabla\":\"entrevistas\",\"id_entrevista\":13,\"estado\":\"Realizada\"}'),
(959, '2026-06-30 20:13:13', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(960, '2026-06-30 20:13:28', 7, 'ELIMINACION', '{\"tabla\":\"entrevistas\",\"registro\":{\"IdEntrevista\":13,\"IdOferente\":13,\"NombreOferente\":\"Jose Pablo Chaves Rojas\",\"IdEmpleado\":7,\"NombreEmpleado\":\"Carlos Andres Mora Solano\",\"FechaEntrevista\":\"2026-07-12T20:11:00\",\"Estado\":\"Realizada\"}}'),
(961, '2026-06-30 20:13:28', 7, 'CONSULTA', '{\"tabla\":\"entrevistas\",\"pagina\":1}'),
(962, '2026-06-30 20:14:49', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(963, '2026-06-30 20:15:11', 4, 'INSERCION', '{\"nuevo\":{\"IdCompania\":0,\"CodigoCompania\":\"CCSSP\",\"Nombre\":\"Caja del seguro\"}}'),
(964, '2026-06-30 20:15:11', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(965, '2026-06-30 20:15:42', 4, 'ACTUALIZACION', '{\"antes\":{\"IdCompania\":7,\"CodigoCompania\":\"CCSSP\",\"Nombre\":\"Caja del seguro\"},\"despues\":{\"IdCompania\":7,\"CodigoCompania\":\"CCSSP\",\"Nombre\":\"Caja del seguro.....\"}}'),
(966, '2026-06-30 20:15:43', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(967, '2026-06-30 20:15:55', 4, 'ELIMINACION', '{\"eliminado\":{\"IdCompania\":7,\"CodigoCompania\":\"CCSSP\",\"Nombre\":\"Caja del seguro.....\"}}'),
(968, '2026-06-30 20:15:55', 4, 'CONSULTA', '{\"mensaje\":\"El usuario consulta compa\\u00F1\\u00EDas\"}'),
(969, '2026-06-30 20:16:18', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(970, '2026-06-30 20:16:33', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(971, '2026-06-30 20:17:33', 7, 'INSERCION', '{\"tabla\":\"admin_area\",\"registro\":{\"IdArea\":5,\"CodigoArea\":\"LOGS\",\"NombreArea\":\"Logistica\",\"IdEmpleado\":4,\"NombreEmpleado\":\"\"}}'),
(972, '2026-06-30 20:17:33', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(973, '2026-06-30 20:17:50', 7, 'ACTUALIZACION', '{\"tabla\":\"admin_area\",\"antes\":{\"IdArea\":5,\"CodigoArea\":\"LOGS\",\"NombreArea\":\"Logistica\",\"IdEmpleado\":4,\"NombreEmpleado\":\"Gabriel Esteban Rojas Vega\"},\"despues\":{\"IdArea\":5,\"CodigoArea\":\"LOGIS\",\"NombreArea\":\"Logistica\",\"IdEmpleado\":4,\"NombreEmpleado\":\"\"}}'),
(974, '2026-06-30 20:17:51', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(975, '2026-06-30 20:17:58', 7, 'ELIMINACION', '{\"tabla\":\"admin_area\",\"registro\":{\"IdArea\":5,\"CodigoArea\":\"LOGIS\",\"NombreArea\":\"Logistica\",\"IdEmpleado\":4,\"NombreEmpleado\":\"Gabriel Esteban Rojas Vega\"}}'),
(976, '2026-06-30 20:17:58', 7, 'CONSULTA', '{\"tabla\":\"admin_area\",\"pagina\":1}'),
(977, '2026-06-30 20:23:51', 4, 'INSERTADO', '{\"tabla\":\"Parametros\"}'),
(978, '2026-06-30 20:24:10', 4, 'EDITADO', '{\"tabla\":\"Parametros\"}'),
(979, '2026-06-30 20:24:18', 4, 'ELIMINACION', '{\"tabla\":\"Parametros\"}'),
(980, '2026-06-30 20:27:23', 4, 'se realizó la carga de información', '{\"tabla\":\"Provincia, Canton, Distrito\"}'),
(981, '2026-06-30 20:29:55', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(982, '2026-06-30 20:30:15', 7, 'Crear GEN5', '{\"mensaje\": \"Se crea institucion educativa\", \"registro\": {\"idInstitucion\": \"19\", \"codigo\": \"UP\", \"nombre\": \"Universidad de Prueba\"}}'),
(983, '2026-06-30 20:30:15', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(984, '2026-06-30 20:30:26', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta una institucion educativa\", \"idInstitucion\": \"19\"}'),
(985, '2026-06-30 20:30:31', 7, 'Actualizar GEN5', '{\"mensaje\": \"Se actualiza institucion educativa\", \"anterior\": {\"idInstitucion\": 19, \"codigo\": \"UP\", \"nombre\": \"Universidad de Prueba\"}, \"actual\": {\"idInstitucion\": 19, \"codigo\": \"UP\", \"nombre\": \"Universidad de Prueba Editada\"}}'),
(986, '2026-06-30 20:30:31', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(987, '2026-06-30 20:30:41', 7, 'Eliminar GEN5', '{\"mensaje\": \"Se elimina institucion educativa\", \"registroEliminado\": {\"idInstitucion\": 19, \"codigo\": \"UP\", \"nombre\": \"Universidad de Prueba Editada\"}}'),
(988, '2026-06-30 20:30:41', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(989, '2026-06-30 20:30:56', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta oferentes\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(990, '2026-06-30 20:30:59', 7, 'Consultar OFE1', '{\"mensaje\": \"El usuario consulta un oferente\", \"idOferente\": \"20\"}'),
(991, '2026-06-30 20:30:59', 7, 'Consultar OFE3', '{\"mensaje\": \"El usuario consulta preparacion academica de un oferente\", \"idOferente\": \"20\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(992, '2026-06-30 20:31:04', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}'),
(993, '2026-06-30 20:31:09', 7, 'Consultar GEN5', '{\"mensaje\": \"El usuario consulta instituciones educativas\", \"pagina\": \"1\", \"tamanoPagina\": \"10\"}');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `canton`
--

CREATE TABLE `canton` (
  `id_canton` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `id_provincia` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `canton`
--

INSERT INTO `canton` (`id_canton`, `nombre`, `id_provincia`) VALUES
(1, 'Central', NULL),
(2, 'Goicochea', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `companias`
--

CREATE TABLE `companias` (
  `id_compania` int(11) NOT NULL,
  `codigo_compania` varchar(50) NOT NULL,
  `nombre` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `companias`
--

INSERT INTO `companias` (`id_compania`, `codigo_compania`, `nombre`) VALUES
(1, 'CP-012', 'Bienes SA'),
(3, 'TD-0101', 'Instituto nacional de seguros'),
(4, 'AS-02', 'ASSA Compañía de Seguros'),
(5, 'CS-03001', 'CCSS – Caja Costarricense de Seguro Social'),
(6, 'LA-002', 'Lagar');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `concursos`
--

CREATE TABLE `concursos` (
  `id_concursos` int(11) NOT NULL,
  `codigo_concurso` varchar(30) NOT NULL,
  `nombre_concurso` varchar(150) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `estado_concur` enum('Vigente','Vencido') NOT NULL DEFAULT 'Vigente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `concursos`
--

INSERT INTO `concursos` (`id_concursos`, `codigo_concurso`, `nombre_concurso`, `fecha_inicio`, `fecha_fin`, `estado_concur`) VALUES
(2, 'CON-2026-001', 'Reclutamiento Administrativo', '2026-06-10', '2026-07-10', 'Vigente'),
(3, 'CON-2026-002', 'Reclutamiento Enfermería', '2026-01-07', '2026-01-08', 'Vigente'),
(4, 'CON-2026-003', 'Reclutamiento Asistente de Recursos Humanos', '2026-01-08', '2026-02-08', 'Vigente'),
(5, 'CON-2026-004', 'Reclutamiento Médico General.', '2026-06-30', '2026-07-30', 'Vigente'),
(6, 'CON-2026-005', 'Reclutamiento Auxiliar Contable', '2026-06-03', '2026-07-03', 'Vigente'),
(7, 'CON-2026-006', 'Reclutamiento Técnico en Farmacia', '2026-06-04', '2026-07-04', 'Vigente'),
(8, 'CON-2026-007', 'Reclutamiento Recepcionista Médico', '2026-06-05', '2026-08-05', 'Vigente'),
(9, 'CON-2026-008', 'Reclutamiento Analista de Nómina', '2026-05-01', '2026-06-01', 'Vigente'),
(10, 'CON-2026-009', 'Reclutamiento Terapeuta Físico', '2026-06-08', '2026-07-08', 'Vigente'),
(11, 'CON-2026-010', 'Reclutamiento Nutricionista', '2026-06-13', '2026-07-13', 'Vigente'),
(12, 'CON-2026-011', 'Reclutamiento Psicólogo Clínico', '2026-06-05', '2026-07-05', 'Vigente'),
(13, 'CON-2026-012', 'Reclutamiento Técnico de Laboratorio', '2026-06-05', '2026-06-07', 'Vigente'),
(14, 'CON-2026-013', 'Asistente de Pacientes', '2026-06-06', '2026-06-07', 'Vigente'),
(15, 'CON-2026-014', 'Reclutamiento Auxiliar de Limpieza', '2026-06-16', '2026-07-16', 'Vencido'),
(18, 'CON-2026-027', 'Doctor Residente', '2026-06-16', '2026-08-16', 'Vigente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `distrito`
--

CREATE TABLE `distrito` (
  `id_distrito` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `id_canton` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `distrito`
--

INSERT INTO `distrito` (`id_distrito`, `nombre`, `id_canton`) VALUES
(2, 'Alajuela', NULL),
(4, 'Cervantes', NULL),
(1, 'mercedes', NULL),
(3, 'Oriental', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `id_empleado` int(11) NOT NULL,
  `numero_empleado` varchar(20) DEFAULT NULL,
  `id_oferente` int(11) DEFAULT NULL,
  `fecha_creacion` date DEFAULT NULL,
  `nombre_completo` varchar(200) DEFAULT NULL,
  `identificacion` varchar(20) DEFAULT NULL,
  `tipo_identificacion` enum('CedulaIdentidad','DIMEX','Pasaporte') DEFAULT NULL,
  `id_puesto` int(11) DEFAULT NULL,
  `fecha_contratacion` date DEFAULT NULL,
  `estado` enum('activo','inactivo') DEFAULT NULL,
  `fecha_modificacion` date DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`id_empleado`, `numero_empleado`, `id_oferente`, `fecha_creacion`, `nombre_completo`, `identificacion`, `tipo_identificacion`, `id_puesto`, `fecha_contratacion`, `estado`, `fecha_modificacion`, `id_usuario`) VALUES
(1, 'EMP001', 1, '2026-06-06', 'Juan Pérez Mora', '123456789', 'CedulaIdentidad', 1, '2026-06-06', 'activo', '2026-06-06', 1),
(2, 'EMP001', 2, '2026-06-07', 'Daniel Perez', '305280498', 'CedulaIdentidad', 2, '2026-06-07', 'activo', '2026-06-07', 2),
(3, 'EMP-20260609155011', 6, '2026-06-09', 'Andres Felipe Castro Gomez', 'A12345678', 'Pasaporte', 3, '2026-06-09', 'activo', NULL, NULL),
(4, 'EMP-20260609155941', 15, '2026-06-09', 'Gabriel Esteban Rojas Vega', 'C45678901', 'Pasaporte', 1, '2026-06-09', 'activo', NULL, NULL),
(5, 'EMP-20260616033523', 2, '2026-06-16', 'Daniel Perez', '305280498', 'CedulaIdentidad', 1, '2026-06-16', 'activo', NULL, NULL),
(6, 'EMP-20260616191716', 6, '2026-06-16', 'Andres Felipe Castro Gomez', 'A12345678', 'Pasaporte', 1, '2026-06-16', 'activo', NULL, NULL),
(7, 'EMP-20260616192136', 4, '2026-06-16', 'Carlos Andres Mora Solano', '118760945', 'CedulaIdentidad', 1, '2026-06-16', 'activo', NULL, NULL),
(8, 'EMP-20260630200445', 2, '2026-06-30', 'Daniel Perez', '305280498', 'CedulaIdentidad', 3, '2026-06-30', 'activo', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entrevistas`
--

CREATE TABLE `entrevistas` (
  `id_entrevista` int(11) NOT NULL,
  `id_oferente` int(11) NOT NULL,
  `id_empleado` int(11) NOT NULL,
  `fecha_entrevista` datetime NOT NULL,
  `estado` enum('Pendiente','Realizada') DEFAULT 'Pendiente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `entrevistas`
--

INSERT INTO `entrevistas` (`id_entrevista`, `id_oferente`, `id_empleado`, `fecha_entrevista`, `estado`) VALUES
(1, 2, 1, '2026-06-17 15:00:00', 'Pendiente'),
(3, 8, 2, '2026-06-24 00:00:00', 'Pendiente'),
(5, 5, 1, '2026-07-01 13:00:00', 'Pendiente'),
(6, 7, 1, '2026-06-17 09:00:00', 'Pendiente'),
(7, 12, 2, '2026-07-01 15:00:00', 'Pendiente'),
(8, 11, 2, '2026-07-28 13:30:00', 'Realizada'),
(9, 6, 1, '2026-06-26 07:15:00', 'Pendiente'),
(11, 12, 5, '2026-07-03 20:10:00', 'Pendiente'),
(12, 19, 4, '2026-07-10 02:16:00', 'Pendiente'),
(14, 18, 7, '2026-07-30 20:12:00', 'Pendiente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `experiencia_laboral`
--

CREATE TABLE `experiencia_laboral` (
  `id_experiencia` int(11) NOT NULL,
  `id_oferente` int(11) NOT NULL,
  `nombre_empresa` varchar(100) NOT NULL,
  `puesto_desempenado` varchar(100) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `experiencia_laboral`
--

INSERT INTO `experiencia_laboral` (`id_experiencia`, `id_oferente`, `nombre_empresa`, `puesto_desempenado`, `fecha_inicio`, `fecha_fin`) VALUES
(1, 13, 'Clínica Señora de los Ángeles', 'Asistente de pacientes', '2024-08-09', '2026-05-15'),
(6, 20, 'Mmvcg12334', 'Deygd', '2026-06-02', '2026-08-13'),
(7, 20, 'Hggh', 'Bjbuj', '2026-06-03', '2026-06-16');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `institu_educa`
--

CREATE TABLE `institu_educa` (
  `id_insti_edu` int(11) NOT NULL,
  `codigo_insti` varchar(30) NOT NULL,
  `nombre` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `institu_educa`
--

INSERT INTO `institu_educa` (`id_insti_edu`, `codigo_insti`, `nombre`) VALUES
(1, 'UNA', 'Universidad Nacional de Costa Rica'),
(2, 'UCR', 'Universidad de Costa Rica'),
(3, 'CUC', 'Colegio Universitario Cartago'),
(4, 'INA', 'Instituto Nacional de Aprendizaje'),
(6, 'UTN', 'Universidad Técnica Nacional'),
(7, 'UNED', 'Universidad Estatal a Distancia'),
(8, 'UACA', 'Universidad Autónoma de Centro América'),
(9, 'ULACIT', 'Universidad Latinoamericana de Ciencia y Tecnología'),
(10, 'UAM', 'Universidad Americana'),
(11, 'UH', 'Universidad Hispanoamericana'),
(12, 'UIA', 'Universidad Internacional de las Américas'),
(13, 'UCART', 'Universidad Florencio del Castillo'),
(14, 'USJ', 'Universidad San José'),
(15, 'ULATINA', 'Universidad Latina de Costa Rica'),
(18, 'UTC', 'Universidad Técnica Central');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oferentes`
--

CREATE TABLE `oferentes` (
  `id_oferente` int(11) NOT NULL,
  `id_persona` int(11) NOT NULL,
  `fecha_regis` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `oferentes`
--

INSERT INTO `oferentes` (`id_oferente`, `id_persona`, `fecha_regis`) VALUES
(1, 1, '2026-06-06 21:14:49'),
(2, 2, '2026-06-07 03:39:26'),
(4, 4, '2026-06-09 12:53:36'),
(5, 5, '2026-06-09 12:54:21'),
(6, 6, '2026-06-09 12:55:21'),
(7, 7, '2026-06-09 12:56:19'),
(8, 8, '2026-06-09 12:56:57'),
(9, 9, '2026-06-09 12:58:22'),
(10, 10, '2026-06-09 12:59:19'),
(11, 11, '2026-06-09 12:59:57'),
(12, 12, '2026-06-09 13:00:37'),
(13, 13, '2026-06-09 13:01:11'),
(14, 14, '2026-06-09 13:01:56'),
(15, 15, '2026-06-09 13:05:10'),
(18, 18, '2026-06-09 13:48:38'),
(19, 19, '2026-06-16 08:26:46'),
(20, 20, '2026-06-16 19:08:48');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oferente_concur`
--

CREATE TABLE `oferente_concur` (
  `id_of_concurso` int(11) NOT NULL,
  `id_oferente` int(11) NOT NULL,
  `id_concursos` int(11) NOT NULL,
  `fecha_asigna` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `oferente_concur`
--

INSERT INTO `oferente_concur` (`id_of_concurso`, `id_oferente`, `id_concursos`, `fecha_asigna`) VALUES
(2, 4, 5, '2026-06-09 12:53:36'),
(3, 4, 15, '2026-06-09 12:53:36'),
(4, 5, 5, '2026-06-09 12:54:21'),
(5, 6, 2, '2026-06-09 12:55:21'),
(6, 7, 11, '2026-06-09 12:56:19'),
(7, 7, 2, '2026-06-09 12:56:19'),
(8, 7, 10, '2026-06-09 12:56:19'),
(9, 8, 3, '2026-06-09 12:56:57'),
(10, 9, 13, '2026-06-09 12:58:22'),
(11, 10, 13, '2026-06-09 12:59:19'),
(12, 11, 7, '2026-06-09 12:59:57'),
(13, 12, 3, '2026-06-09 13:00:37'),
(14, 13, 14, '2026-06-09 13:01:11'),
(18, 14, 8, '2026-06-09 13:02:25'),
(19, 14, 3, '2026-06-09 13:02:25'),
(24, 15, 9, '2026-06-09 13:30:53'),
(30, 18, 5, '2026-06-16 07:03:28'),
(31, 18, 15, '2026-06-16 07:03:28'),
(32, 19, 10, '2026-06-16 08:26:46'),
(33, 19, 8, '2026-06-16 08:26:46'),
(36, 20, 5, '2026-06-16 19:11:06');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oferente_correo`
--

CREATE TABLE `oferente_correo` (
  `id_of_correo` int(11) NOT NULL,
  `id_oferente` int(11) NOT NULL,
  `correo` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `oferente_correo`
--

INSERT INTO `oferente_correo` (`id_of_correo`, `id_oferente`, `correo`) VALUES
(2, 4, 'carlos.mora@gmail.com'),
(3, 5, 'maria.rojas@hotmail.com'),
(4, 6, 'andres.castro@yahoo.com'),
(5, 7, 'daniela.hernandez@yahoo.com'),
(6, 7, 'daniela.h2@gmail.com.com'),
(7, 8, 'valeria.jimenez@test.com'),
(8, 9, 'luis.porras@mail.com'),
(9, 10, 'sofia.vergara@gmail.com'),
(10, 11, 'ricardo.lopez@test.com'),
(11, 12, 'camila.soto@test.com'),
(12, 13, 'jose.chaves@test.com'),
(14, 14, 'natalia.castro@test.com'),
(19, 15, 'gabriel.rojas@hotmail.com'),
(23, 18, 'OFE13@gmail.com'),
(24, 19, 'Jr@gmail.com'),
(27, 20, 'kennethprueba@gmail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oferente_requisito`
--

CREATE TABLE `oferente_requisito` (
  `id_of_requisito` int(11) NOT NULL,
  `id_oferente` int(11) NOT NULL,
  `id_requisito` int(11) NOT NULL,
  `fecha_asigna` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oferente_telf`
--

CREATE TABLE `oferente_telf` (
  `id_of_telefono` int(11) NOT NULL,
  `id_oferente` int(11) NOT NULL,
  `telefono` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `oferente_telf`
--

INSERT INTO `oferente_telf` (`id_of_telefono`, `id_oferente`, `telefono`) VALUES
(2, 4, '88887777'),
(3, 5, '87776666'),
(4, 6, '86665555'),
(5, 6, '86241512'),
(6, 7, '89998888'),
(7, 7, '86241512'),
(8, 8, '84561234'),
(9, 9, '83334444'),
(10, 10, '82221111'),
(11, 11, '81112222'),
(12, 12, '89990000'),
(13, 13, '87001122'),
(15, 14, '86003344'),
(20, 15, '85005566'),
(24, 18, '21232125'),
(25, 19, '89743532'),
(28, 20, '60211214');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pantallas`
--

CREATE TABLE `pantallas` (
  `id_pantalla` int(11) NOT NULL,
  `nombre_pantalla` varchar(100) NOT NULL,
  `fecha_creacion` datetime DEFAULT current_timestamp(),
  `fecha_modificacion` datetime DEFAULT NULL,
  `activo` tinyint(4) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `pantallas`
--

INSERT INTO `pantallas` (`id_pantalla`, `nombre_pantalla`, `fecha_creacion`, `fecha_modificacion`, `activo`) VALUES
(1, 'Inicio', '2026-06-07 18:55:35', NULL, 1),
(2, 'Usuarios', '2026-06-07 18:55:35', NULL, 1),
(3, 'Roles', '2026-06-07 18:55:35', NULL, 1),
(4, 'Pantallas', '2026-06-07 18:55:35', NULL, 1),
(5, 'Parámetros', '2026-06-07 18:55:35', NULL, 1),
(6, 'Bitácora', '2026-06-07 18:55:35', NULL, 1),
(7, 'Cargar Datos de Ubicación', '2026-06-07 18:55:35', NULL, 1),
(8, 'Compañías', '2026-06-07 18:55:35', NULL, 1),
(10, 'Oferentes', '2026-06-07 20:37:35', NULL, 1),
(11, 'Concursos', '2026-06-07 20:37:35', NULL, 1),
(12, 'Agendar Entrevistas', '2026-06-07 20:37:35', NULL, 1),
(13, 'Contratar Empleado', '2026-06-07 20:37:35', NULL, 1),
(14, 'Puestos', '2026-06-07 20:37:35', NULL, 1),
(15, 'Áreas', '2026-06-07 20:37:35', NULL, 1),
(16, 'Acciones de Personal', '2026-06-07 20:37:35', NULL, 1),
(17, 'Instituciones Educativas', '2026-06-07 20:37:35', NULL, 1),
(21, 'Pantalla Nueva Editar', '2026-06-09 16:05:36', '2026-06-09 16:08:10', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `parametros`
--

CREATE TABLE `parametros` (
  `id_parametro` int(11) NOT NULL,
  `codigo_parametro` varchar(100) NOT NULL,
  `valor` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `parametros`
--

INSERT INTO `parametros` (`id_parametro`, `codigo_parametro`, `valor`) VALUES
(2, 'LONGITUD_USUARIO', '50'),
(3, 'LONGITUD_COD_AREA', '20'),
(4, 'LONGITUD_COD_COMPANIA', '50'),
(5, 'LONGITUD_EXP_NOMBRE_EMPRESA', '100'),
(6, 'LONGITUD_EXP_PUESTO', '100'),
(7, 'LONGITUD_NOMBRE_AREA', '100'),
(8, 'LONGITUD_NOMBRE_COMPANIA', '150'),
(9, 'LONGITUD_NOMBRE_ROL', '50'),
(10, 'LONGITUD_USUARIO_EDIT', '50'),
(12, 'Prueba', '12');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personas`
--

CREATE TABLE `personas` (
  `id_persona` int(11) NOT NULL,
  `identificacion` varchar(30) NOT NULL,
  `tipo_identificacion` enum('CedulaIdentidad','DIMEX','Pasaporte') NOT NULL,
  `nombre_comple` varchar(150) NOT NULL,
  `fecha_naci` date NOT NULL,
  `tipo_perso` enum('Oferente','Empleado') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `personas`
--

INSERT INTO `personas` (`id_persona`, `identificacion`, `tipo_identificacion`, `nombre_comple`, `fecha_naci`, `tipo_perso`) VALUES
(1, '123456789', 'CedulaIdentidad', 'Juan Pérez Mora', '1990-05-10', 'Empleado'),
(2, '305280498', 'CedulaIdentidad', 'Daniel Perez', '1990-05-10', 'Empleado'),
(4, '118760945', 'CedulaIdentidad', 'Carlos Andres Mora Solano', '1998-12-04', 'Oferente'),
(5, '702340981', 'CedulaIdentidad', 'Maria Fernanda Rojas Vargas', '1996-09-22', 'Oferente'),
(6, 'A12345678', 'Pasaporte', 'Andres Felipe Castro Gomez', '1994-12-02', 'Oferente'),
(7, '155812345678', 'DIMEX', 'Daniela Sofia Hernandez Ruiz', '1999-03-11', 'Oferente'),
(8, '304560789', 'CedulaIdentidad', 'Valeria Jimenez Araya', '2000-05-26', 'Oferente'),
(9, '205670432', 'CedulaIdentidad', 'Luis Diego Porras Salazar', '1995-01-14', 'Oferente'),
(10, '109870654', 'CedulaIdentidad', 'Sofia Elena Vergara Mena', '1985-12-14', 'Oferente'),
(11, 'B98765432', 'Pasaporte', 'Ricardo Antonio Lopez Marin', '1990-12-15', 'Oferente'),
(12, '155898765432', 'DIMEX', 'Camila Andrea Soto Peña', '1998-10-28', 'Oferente'),
(13, '402780123', 'CedulaIdentidad', 'Jose Pablo Chaves Rojas', '1998-11-12', 'Oferente'),
(14, '603450987', 'CedulaIdentidad', 'Natalia Fernanda Castro Mora', '1999-12-19', 'Oferente'),
(15, 'C45678901', 'Pasaporte', 'Gabriel Esteban Rojas Vega', '1996-07-24', 'Oferente'),
(18, 'C45678902', 'Pasaporte', 'Prueba OFETres', '1990-11-13', 'Oferente'),
(19, '114365432', 'CedulaIdentidad', 'Julio Rosales', '1994-05-16', 'Oferente'),
(20, '112545121', 'CedulaIdentidad', 'Kenneth Prueba Editado', '1997-11-12', 'Oferente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prepara_academica`
--

CREATE TABLE `prepara_academica` (
  `id_pre_academica` int(11) NOT NULL,
  `id_oferente` int(11) NOT NULL,
  `id_insti_edu` int(11) NOT NULL,
  `titulo_obtenido` varchar(100) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `prepara_academica`
--

INSERT INTO `prepara_academica` (`id_pre_academica`, `id_oferente`, `id_insti_edu`, `titulo_obtenido`, `fecha_inicio`, `fecha_fin`) VALUES
(1, 15, 4, 'Analisis de Nóminas', '2023-11-22', '2026-06-08'),
(2, 14, 10, 'Reclutamiento Enfermería', '2025-01-08', '2026-06-08'),
(3, 14, 8, 'Reclutamiento Recepcionista Médico', '2022-01-04', '2024-01-04'),
(4, 13, 13, 'Asistente de Pacientes', '2021-01-01', '2023-01-01'),
(5, 12, 14, 'Reclutamiento Enfermería', '2024-06-09', '2026-06-09'),
(6, 11, 6, 'Reclutamiento Técnico en Farmacia', '2023-06-05', '2026-06-05'),
(7, 10, 7, 'Reclutamiento Técnico de Laboratorio', '2023-02-01', '2026-02-01'),
(8, 9, 2, 'Reclutamiento Técnico de Laboratorio', '2024-05-02', '2024-05-02'),
(9, 8, 9, 'Reclutamiento Enfermería', '2020-02-01', '2026-02-01'),
(10, 7, 3, 'Reclutamiento Administrativo', '2021-02-02', '2023-02-02'),
(11, 7, 4, 'Reclutamiento Terapeuta Físico', '2022-02-05', '2024-02-05'),
(12, 7, 15, 'Reclutamiento Nutricionista', '2025-02-20', '2026-02-20'),
(13, 6, 1, 'Reclutamiento Administrativo', '2021-12-20', '2024-12-20'),
(14, 5, 15, 'Reclutamiento Médico General', '2019-11-12', '2026-11-12'),
(16, 19, 7, 'Estudios Generales', '2022-06-16', '2026-06-15'),
(17, 20, 3, 'Tecnologias de informacion', '2020-11-12', '2024-11-12');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `provincias`
--

CREATE TABLE `provincias` (
  `id_provincia` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `provincias`
--

INSERT INTO `provincias` (`id_provincia`, `nombre`) VALUES
(2, 'Alajuela'),
(3, 'Cartago'),
(1, 'San José'),
(4, 'Sanjose');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `puestos`
--

CREATE TABLE `puestos` (
  `id_puesto` int(11) NOT NULL,
  `codigo_puesto` varchar(20) DEFAULT NULL,
  `nombre_puesto` varchar(150) DEFAULT NULL,
  `monto_salario` decimal(12,2) DEFAULT NULL,
  `id_puesto_jefac` int(11) DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT NULL,
  `fecha_modificacion` datetime DEFAULT NULL,
  `activo` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `puestos`
--

INSERT INTO `puestos` (`id_puesto`, `codigo_puesto`, `nombre_puesto`, `monto_salario`, `id_puesto_jefac`, `fecha_creacion`, `fecha_modificacion`, `activo`) VALUES
(1, 'GER001', 'Gerente General', 1500000.00, NULL, '2026-06-06 21:14:25', '2026-06-30 20:04:15', 0),
(2, 'GER001', 'Operario', 1500000.00, NULL, '2026-06-07 03:38:47', '2026-06-07 03:38:47', 1),
(3, 'P-2026-001', 'Medico General', 10000.00, NULL, '2026-06-09 15:49:55', NULL, 1),
(4, 'GER005', 'Gerente Medico', 500000.00, NULL, '2026-06-16 19:24:07', NULL, 1),
(5, 'GER008', 'opefefww', 200012.00, NULL, '2026-06-30 20:01:20', '2026-06-30 20:04:04', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `requisitos_puesto`
--

CREATE TABLE `requisitos_puesto` (
  `id_requisito` int(11) NOT NULL,
  `id_puesto` int(11) DEFAULT NULL,
  `nombre_requisito` varchar(200) NOT NULL DEFAULT '',
  `fecha_creacion` datetime DEFAULT NULL,
  `fecha_modificacion` datetime DEFAULT NULL,
  `activo` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `requisitos_puesto`
--

INSERT INTO `requisitos_puesto` (`id_requisito`, `id_puesto`, `nombre_requisito`, `fecha_creacion`, `fecha_modificacion`, `activo`) VALUES
(1, 4, 'prueba2', '2026-06-16 19:24:40', NULL, 1),
(2, 5, 'pruebaaaa', '2026-06-30 20:02:25', '2026-06-30 20:03:03', 0),
(3, 5, 'dasdsaa', '2026-06-30 20:02:39', NULL, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id_rol` int(11) NOT NULL,
  `nombre_permiso` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id_rol`, `nombre_permiso`) VALUES
(1, 'Administrador'),
(2, 'Usuario'),
(10, 'Master'),
(12, 'Prueba');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rolpantalla`
--

CREATE TABLE `rolpantalla` (
  `id_rol` int(11) NOT NULL,
  `id_pantalla` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `rolpantalla`
--

INSERT INTO `rolpantalla` (`id_rol`, `id_pantalla`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(2, 1),
(2, 10),
(2, 11),
(2, 12),
(2, 13),
(2, 14),
(2, 15),
(2, 16),
(2, 17),
(10, 1),
(10, 2),
(10, 3),
(10, 4),
(10, 5),
(10, 6),
(10, 7),
(10, 8),
(10, 10),
(10, 11),
(10, 12),
(10, 13),
(10, 14),
(10, 15),
(10, 16),
(10, 17),
(10, 21),
(12, 16);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuariorol`
--

CREATE TABLE `usuariorol` (
  `id_usuario` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuariorol`
--

INSERT INTO `usuariorol` (`id_usuario`, `id_rol`) VALUES
(4, 1),
(7, 2),
(8, 1),
(12, 10),
(13, 1),
(14, 12);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `usuario` varchar(50) NOT NULL,
  `contrasena` varchar(255) NOT NULL,
  `activo` tinyint(4) NOT NULL,
  `fecha_modifi` datetime DEFAULT NULL,
  `fecha_access` datetime DEFAULT NULL,
  `nombre_completo` varchar(150) DEFAULT NULL,
  `correo` varchar(150) DEFAULT NULL,
  `estado` varchar(20) DEFAULT 'Activo',
  `intentos_fallidos` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `usuario`, `contrasena`, `activo`, `fecha_modifi`, `fecha_access`, `nombre_completo`, `correo`, `estado`, `intentos_fallidos`) VALUES
(4, 'Admin', 'RbJ8lrV4nl1sF0ZMDS4c5Mu+qoriSLDymamA4805voqBuQ66+ow=', 1, '2026-06-07 14:54:41', NULL, 'Geovanny Cervantes Calderon', 'geovanny22c.c@gmail.com', 'Activo', 0),
(7, 'Usuario', '8hWXrHPPKRsPkfiJ7TLVJD+5gm3Hm6Nr3ioHK47Vb0xJ+CprTaI=', 1, '2026-06-07 19:27:20', NULL, 'Merlin Hernandez', 'ericucho123@gmail.com', 'Activo', 0),
(8, 'Administrador', 'o9sX3dmxyyNi3ZQAJBCzM0JySQHavXtqyE6JkyIOspZ9MC2C1Sg=', 1, '2026-06-09 01:11:50', NULL, 'Antony Cervantes Calderon', 'antonny22c.c@gmail.com', 'Activo', 3),
(12, 'Master', 'txZnYJrRQJwdfTJXCzee2bYcE0uSybaB2mcQkDydnKw4fSnP22E=', 1, '2026-06-16 15:03:09', NULL, 'Erick Hernández Arley', 'ericucho123126@gmail.com', 'Activo', 0),
(13, 'Tony', 'W1X7oxEUMJCf2sM7W8f0+NfgQ5ve2JVcPy3vYc7J2qsOoU/yURo=', 1, '2026-06-16 18:49:43', NULL, 'Erick Hernández Arley', 'ericucho123126@gmail.com', 'Inactivo', 3),
(14, 'Arley', '0fAeLesjx9T3UCJzcTdDagesLJyra0T+HVeoxcjngc5fZmdmSFg=', 1, '2026-06-16 19:04:04', NULL, 'Erick Hernandez Arley', 'ericucho1223126@gmail.com', 'Activo', 0);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `accion_personal`
--
ALTER TABLE `accion_personal`
  ADD PRIMARY KEY (`id_accion`),
  ADD KEY `id_empleado` (`id_empleado`),
  ADD KEY `id_jefactura` (`id_jefactura`);

--
-- Indices de la tabla `admin_area`
--
ALTER TABLE `admin_area`
  ADD PRIMARY KEY (`id_area`);

--
-- Indices de la tabla `bitacoras`
--
ALTER TABLE `bitacoras`
  ADD PRIMARY KEY (`id_bitacoras`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `canton`
--
ALTER TABLE `canton`
  ADD PRIMARY KEY (`id_canton`),
  ADD UNIQUE KEY `nombre` (`nombre`,`id_provincia`),
  ADD KEY `id_provincia` (`id_provincia`);

--
-- Indices de la tabla `companias`
--
ALTER TABLE `companias`
  ADD PRIMARY KEY (`id_compania`),
  ADD UNIQUE KEY `uq_codigo_compania` (`codigo_compania`);

--
-- Indices de la tabla `concursos`
--
ALTER TABLE `concursos`
  ADD PRIMARY KEY (`id_concursos`),
  ADD UNIQUE KEY `codigo_concurso` (`codigo_concurso`);

--
-- Indices de la tabla `distrito`
--
ALTER TABLE `distrito`
  ADD PRIMARY KEY (`id_distrito`),
  ADD UNIQUE KEY `nombre` (`nombre`,`id_canton`),
  ADD KEY `id_canton` (`id_canton`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`id_empleado`),
  ADD UNIQUE KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_oferente` (`id_oferente`),
  ADD KEY `id_puesto` (`id_puesto`);

--
-- Indices de la tabla `entrevistas`
--
ALTER TABLE `entrevistas`
  ADD PRIMARY KEY (`id_entrevista`),
  ADD KEY `entrevistas_ibfk_1` (`id_oferente`),
  ADD KEY `entrevistas_ibfk_2` (`id_empleado`);

--
-- Indices de la tabla `experiencia_laboral`
--
ALTER TABLE `experiencia_laboral`
  ADD PRIMARY KEY (`id_experiencia`),
  ADD KEY `experiencia_laboral_ibfk_1` (`id_oferente`);

--
-- Indices de la tabla `institu_educa`
--
ALTER TABLE `institu_educa`
  ADD PRIMARY KEY (`id_insti_edu`),
  ADD UNIQUE KEY `codigo_insti` (`codigo_insti`);

--
-- Indices de la tabla `oferentes`
--
ALTER TABLE `oferentes`
  ADD PRIMARY KEY (`id_oferente`),
  ADD UNIQUE KEY `id_persona` (`id_persona`);

--
-- Indices de la tabla `oferente_concur`
--
ALTER TABLE `oferente_concur`
  ADD PRIMARY KEY (`id_of_concurso`),
  ADD UNIQUE KEY `id_oferente` (`id_oferente`,`id_concursos`),
  ADD KEY `id_concursos` (`id_concursos`);

--
-- Indices de la tabla `oferente_correo`
--
ALTER TABLE `oferente_correo`
  ADD PRIMARY KEY (`id_of_correo`),
  ADD KEY `id_oferente` (`id_oferente`);

--
-- Indices de la tabla `oferente_requisito`
--
ALTER TABLE `oferente_requisito`
  ADD PRIMARY KEY (`id_of_requisito`),
  ADD KEY `id_oferente` (`id_oferente`),
  ADD KEY `id_requisito` (`id_requisito`);

--
-- Indices de la tabla `oferente_telf`
--
ALTER TABLE `oferente_telf`
  ADD PRIMARY KEY (`id_of_telefono`),
  ADD KEY `id_oferente` (`id_oferente`);

--
-- Indices de la tabla `pantallas`
--
ALTER TABLE `pantallas`
  ADD PRIMARY KEY (`id_pantalla`);

--
-- Indices de la tabla `parametros`
--
ALTER TABLE `parametros`
  ADD PRIMARY KEY (`id_parametro`);

--
-- Indices de la tabla `personas`
--
ALTER TABLE `personas`
  ADD PRIMARY KEY (`id_persona`),
  ADD UNIQUE KEY `identificacion` (`identificacion`);

--
-- Indices de la tabla `prepara_academica`
--
ALTER TABLE `prepara_academica`
  ADD PRIMARY KEY (`id_pre_academica`),
  ADD KEY `id_oferente` (`id_oferente`),
  ADD KEY `id_insti_edu` (`id_insti_edu`);

--
-- Indices de la tabla `provincias`
--
ALTER TABLE `provincias`
  ADD PRIMARY KEY (`id_provincia`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `puestos`
--
ALTER TABLE `puestos`
  ADD PRIMARY KEY (`id_puesto`),
  ADD KEY `id_puesto_jefac` (`id_puesto_jefac`);

--
-- Indices de la tabla `requisitos_puesto`
--
ALTER TABLE `requisitos_puesto`
  ADD PRIMARY KEY (`id_requisito`),
  ADD KEY `id_puesto` (`id_puesto`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id_rol`);

--
-- Indices de la tabla `rolpantalla`
--
ALTER TABLE `rolpantalla`
  ADD PRIMARY KEY (`id_rol`,`id_pantalla`),
  ADD KEY `FK_RolPantalla_Pantalla` (`id_pantalla`);

--
-- Indices de la tabla `usuariorol`
--
ALTER TABLE `usuariorol`
  ADD PRIMARY KEY (`id_usuario`,`id_rol`),
  ADD KEY `id_rol` (`id_rol`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `accion_personal`
--
ALTER TABLE `accion_personal`
  MODIFY `id_accion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `admin_area`
--
ALTER TABLE `admin_area`
  MODIFY `id_area` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `bitacoras`
--
ALTER TABLE `bitacoras`
  MODIFY `id_bitacoras` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=994;

--
-- AUTO_INCREMENT de la tabla `canton`
--
ALTER TABLE `canton`
  MODIFY `id_canton` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `companias`
--
ALTER TABLE `companias`
  MODIFY `id_compania` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `concursos`
--
ALTER TABLE `concursos`
  MODIFY `id_concursos` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de la tabla `distrito`
--
ALTER TABLE `distrito`
  MODIFY `id_distrito` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `id_empleado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `entrevistas`
--
ALTER TABLE `entrevistas`
  MODIFY `id_entrevista` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `experiencia_laboral`
--
ALTER TABLE `experiencia_laboral`
  MODIFY `id_experiencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `institu_educa`
--
ALTER TABLE `institu_educa`
  MODIFY `id_insti_edu` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de la tabla `oferentes`
--
ALTER TABLE `oferentes`
  MODIFY `id_oferente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `oferente_concur`
--
ALTER TABLE `oferente_concur`
  MODIFY `id_of_concurso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT de la tabla `oferente_correo`
--
ALTER TABLE `oferente_correo`
  MODIFY `id_of_correo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT de la tabla `oferente_requisito`
--
ALTER TABLE `oferente_requisito`
  MODIFY `id_of_requisito` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `oferente_telf`
--
ALTER TABLE `oferente_telf`
  MODIFY `id_of_telefono` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT de la tabla `pantallas`
--
ALTER TABLE `pantallas`
  MODIFY `id_pantalla` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `parametros`
--
ALTER TABLE `parametros`
  MODIFY `id_parametro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `personas`
--
ALTER TABLE `personas`
  MODIFY `id_persona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `prepara_academica`
--
ALTER TABLE `prepara_academica`
  MODIFY `id_pre_academica` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `provincias`
--
ALTER TABLE `provincias`
  MODIFY `id_provincia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `puestos`
--
ALTER TABLE `puestos`
  MODIFY `id_puesto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `requisitos_puesto`
--
ALTER TABLE `requisitos_puesto`
  MODIFY `id_requisito` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `accion_personal`
--
ALTER TABLE `accion_personal`
  ADD CONSTRAINT `accion_personal_ibfk_1` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`),
  ADD CONSTRAINT `accion_personal_ibfk_2` FOREIGN KEY (`id_jefactura`) REFERENCES `empleados` (`id_empleado`);

--
-- Filtros para la tabla `canton`
--
ALTER TABLE `canton`
  ADD CONSTRAINT `canton_ibfk_1` FOREIGN KEY (`id_provincia`) REFERENCES `provincias` (`id_provincia`);

--
-- Filtros para la tabla `oferente_requisito`
--
ALTER TABLE `oferente_requisito`
  ADD CONSTRAINT `oferente_requisito_ibfk_1` FOREIGN KEY (`id_oferente`) REFERENCES `oferentes` (`id_oferente`),
  ADD CONSTRAINT `oferente_requisito_ibfk_2` FOREIGN KEY (`id_requisito`) REFERENCES `requisitos_puesto` (`id_requisito`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
