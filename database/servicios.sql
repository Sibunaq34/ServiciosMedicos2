-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3307
-- Tiempo de generación: 21-07-2026 a las 20:01:53
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarPasswordCifradaUsuario` (IN `pIdUsuario` INT, IN `pPasswordCifrada` VARCHAR(255))   BEGIN
    UPDATE `usuarios`
    SET
        `contrasena` = `pPasswordCifrada`,
        `fecha_modifi` = NOW()
    WHERE `id_usuario` = `pIdUsuario`;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarIntentoFallido` (IN `pIdUsuario` INT)   BEGIN
    UPDATE `usuarios`
    SET
        `intentos_fallidos` = LEAST(COALESCE(`intentos_fallidos`, 0) + 1, 3),
        `estado` = CASE
            WHEN `intentos_fallidos` >= 3 THEN 'Bloqueado'
            ELSE `estado`
        END,
        `activo` = CASE
            WHEN `intentos_fallidos` >= 3 THEN 0
            ELSE `activo`
        END,
        `fecha_modifi` = NOW()
    WHERE `id_usuario` = `pIdUsuario`;

    SELECT COALESCE(`intentos_fallidos`, 0)
    FROM `usuarios`
    WHERE `id_usuario` = `pIdUsuario`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ReiniciarIntentosFallidos` (IN `pIdUsuario` INT)   BEGIN
    UPDATE `usuarios`
    SET
        `intentos_fallidos` = 0,
        `fecha_access` = NOW()
    WHERE `id_usuario` = `pIdUsuario`;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_aut3_registrar_oferente_puesto` (IN `pTipoIdentificacion` VARCHAR(20), IN `pIdentificacion` VARCHAR(30), IN `pNombreCompleto` VARCHAR(150), IN `pFechaNacimiento` DATE, IN `pCorreosJson` LONGTEXT, IN `pTelefonosJson` LONGTEXT, IN `pCodigoPuesto` VARCHAR(20), IN `pRutaCurriculum` VARCHAR(500), IN `pNombreCurriculum` VARCHAR(255), IN `pMimeCurriculum` VARCHAR(120), IN `pTamanioCurriculum` INT UNSIGNED, IN `pIdUsuarioTecnico` INT)   BEGIN
  DECLARE vIdPersona INT;
  DECLARE vIdOferente INT;
  DECLARE vIdPuesto INT;
  DECLARE vIdOferentePuesto INT;
  DECLARE vNombrePuesto VARCHAR(150);
  DECLARE vIndex INT DEFAULT 0;
  DECLARE vCompareIndex INT DEFAULT 0;
  DECLARE vTotal INT DEFAULT 0;
  DECLARE vCorreo VARCHAR(150);
  DECLARE vCorreoComparar VARCHAR(150);
  DECLARE vTelefono VARCHAR(20);
  DECLARE vTelefonoComparar VARCHAR(20);
  DECLARE vRegistro LONGTEXT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  IF pTipoIdentificacion IS NULL
     OR pTipoIdentificacion NOT IN ('CedulaIdentidad', 'DIMEX', 'Pasaporte') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El tipo de identificacion no es valido.';
  END IF;

  IF pIdentificacion IS NULL OR TRIM(pIdentificacion) = '' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'La identificacion es requerida.';
  END IF;

  IF pNombreCompleto IS NULL OR TRIM(pNombreCompleto) = '' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El nombre completo es requerido.';
  END IF;

  IF pFechaNacimiento IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'La fecha de nacimiento es requerida.';
  END IF;

  IF pCodigoPuesto IS NULL OR TRIM(pCodigoPuesto) = '' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El codigo del puesto es requerido.';
  END IF;

  IF pRutaCurriculum IS NULL OR TRIM(pRutaCurriculum) = ''
     OR pNombreCurriculum IS NULL OR TRIM(pNombreCurriculum) = ''
     OR pMimeCurriculum IS NULL OR TRIM(pMimeCurriculum) = ''
     OR pTamanioCurriculum IS NULL OR pTamanioCurriculum <= 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'La informacion del curriculum es requerida.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM `usuarios`
    WHERE `id_usuario` = pIdUsuarioTecnico
      AND `usuario` = 'AUT_PUBLICO'
      AND `activo` = 0
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El usuario tecnico de AUT3 no es valido.';
  END IF;

  SELECT `id_puesto`, `nombre_puesto`
  INTO vIdPuesto, vNombrePuesto
  FROM `puestos`
  WHERE `codigo_puesto` = TRIM(pCodigoPuesto)
    AND `activo` = 1
  ORDER BY `id_puesto` ASC
  LIMIT 1;

  IF vIdPuesto IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El puesto indicado no existe o no esta activo.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM `personas`
    WHERE `identificacion` = TRIM(pIdentificacion)
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

    SET vCompareIndex = 0;
    WHILE vCompareIndex < vIndex DO
      SET vCorreoComparar = TRIM(JSON_UNQUOTE(JSON_EXTRACT(pCorreosJson, CONCAT('$[', vCompareIndex, ']'))));

      IF LOWER(vCorreoComparar) = LOWER(vCorreo) THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'No se deben repetir correos.';
      END IF;

      SET vCompareIndex = vCompareIndex + 1;
    END WHILE;

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

    IF vTelefono NOT REGEXP '^[0-9]{8}$' THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El telefono debe contener 8 digitos.';
    END IF;

    SET vCompareIndex = 0;
    WHILE vCompareIndex < vIndex DO
      SET vTelefonoComparar = TRIM(JSON_UNQUOTE(JSON_EXTRACT(pTelefonosJson, CONCAT('$[', vCompareIndex, ']'))));

      IF vTelefonoComparar = vTelefono THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'No se deben repetir telefonos.';
      END IF;

      SET vCompareIndex = vCompareIndex + 1;
    END WHILE;

    SET vIndex = vIndex + 1;
  END WHILE;

  START TRANSACTION;

  INSERT INTO `personas` (
    `identificacion`,
    `tipo_identificacion`,
    `nombre_comple`,
    `fecha_naci`,
    `tipo_perso`
  )
  VALUES (
    TRIM(pIdentificacion),
    pTipoIdentificacion,
    TRIM(pNombreCompleto),
    pFechaNacimiento,
    'Oferente'
  );

  SET vIdPersona = LAST_INSERT_ID();

  INSERT INTO `oferentes` (`id_persona`)
  VALUES (vIdPersona);

  SET vIdOferente = LAST_INSERT_ID();

  SET vIndex = 0;
  SET vTotal = JSON_LENGTH(pCorreosJson);
  WHILE vIndex < vTotal DO
    SET vCorreo = TRIM(JSON_UNQUOTE(JSON_EXTRACT(pCorreosJson, CONCAT('$[', vIndex, ']'))));

    INSERT INTO `oferente_correo` (`id_oferente`, `correo`)
    VALUES (vIdOferente, vCorreo);

    SET vIndex = vIndex + 1;
  END WHILE;

  SET vIndex = 0;
  SET vTotal = JSON_LENGTH(pTelefonosJson);
  WHILE vIndex < vTotal DO
    SET vTelefono = TRIM(JSON_UNQUOTE(JSON_EXTRACT(pTelefonosJson, CONCAT('$[', vIndex, ']'))));

    INSERT INTO `oferente_telf` (`id_oferente`, `telefono`)
    VALUES (vIdOferente, vTelefono);

    SET vIndex = vIndex + 1;
  END WHILE;

  INSERT INTO `oferente_puesto` (
    `id_oferente`,
    `id_puesto`,
    `estado`,
    `ruta_curriculum`,
    `nombre_curriculum`,
    `mime_curriculum`,
    `tamanio_curriculum`
  )
  VALUES (
    vIdOferente,
    vIdPuesto,
    'Postulado',
    TRIM(pRutaCurriculum),
    TRIM(pNombreCurriculum),
    TRIM(pMimeCurriculum),
    pTamanioCurriculum
  );

  SET vIdOferentePuesto = LAST_INSERT_ID();

  SET vRegistro = JSON_OBJECT(
    'idPersona', vIdPersona,
    'idOferente', vIdOferente,
    'idPuesto', vIdPuesto,
    'idOferentePuesto', vIdOferentePuesto,
    'identificacion', TRIM(pIdentificacion),
    'tipoIdentificacion', pTipoIdentificacion,
    'nombreCompleto', TRIM(pNombreCompleto),
    'codigoPuesto', TRIM(pCodigoPuesto),
    'nombrePuesto', vNombrePuesto,
    'correos', JSON_EXTRACT(pCorreosJson, '$'),
    'telefonos', JSON_EXTRACT(pTelefonosJson, '$'),
    'curriculum', JSON_OBJECT(
      'ruta', TRIM(pRutaCurriculum),
      'nombre', TRIM(pNombreCurriculum),
      'mime', TRIM(pMimeCurriculum),
      'tamanio', pTamanioCurriculum
    )
  );

  INSERT INTO `bitacoras` (`id_usuario`, `accion`, `descripcionAccion`)
  VALUES (
    pIdUsuarioTecnico,
    'Crear AUT3',
    JSON_OBJECT(
      'mensaje', 'Se registra oferente publico para puesto',
      'registro', JSON_EXTRACT(vRegistro, '$')
    )
  );

  COMMIT;

  SELECT
    vIdPersona AS id_persona,
    vIdOferente AS id_oferente,
    vIdPuesto AS id_puesto,
    vIdOferentePuesto AS id_oferente_puesto,
    TRIM(pCodigoPuesto) AS codigo_puesto,
    vNombrePuesto AS nombre_puesto;
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
        p.`id_puesto` AS `IdPuesto`,
        p.`codigo_puesto` AS `CodigoPuesto`,
        p.`nombre_puesto` AS `NombrePuesto`,
        p.`monto_salario` AS `MontoSalario`,
        p.`id_puesto_jefac` AS `IdPuestoJefac`,
        j.`nombre_puesto` AS `Jefatura`
    FROM `puestos` p
    LEFT JOIN `puestos` j
        ON j.`id_puesto` = p.`id_puesto_jefac`
    WHERE p.`activo` = 1
    ORDER BY p.`nombre_puesto` ASC;
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
    DECLARE `vIdPuesto` INT DEFAULT NULL;

    SELECT `id_puesto`
      INTO `vIdPuesto`
      FROM `puestos`
     WHERE `codigo_puesto` = TRIM(`pCodigoPuesto`)
       AND `activo` = 1
     LIMIT 1;

    IF `vIdPuesto` IS NULL THEN
        -- Mantiene el contrato esperado por Dapper/WCF, pero sin filas.
        SELECT
            CAST(NULL AS SIGNED) AS `IdOferente`,
            CAST(NULL AS CHAR(150)) AS `NombreCompleto`,
            CAST(NULL AS CHAR(30)) AS `Identificacion`
        WHERE 1 = 0;
    ELSE
        SELECT DISTINCT
            `o`.`id_oferente` AS `IdOferente`,
            `p`.`nombre_comple` AS `NombreCompleto`,
            `p`.`identificacion` AS `Identificacion`
        FROM `oferente_puesto` AS `op`
        INNER JOIN `oferentes` AS `o`
            ON `o`.`id_oferente` = `op`.`id_oferente`
        INNER JOIN `personas` AS `p`
            ON `p`.`id_persona` = `o`.`id_persona`
        WHERE `op`.`id_puesto` = `vIdPuesto`
          AND `op`.`estado` = 'Postulado'
          AND NOT EXISTS (
              SELECT 1
              FROM `requisitos_puesto` AS `rp`
              WHERE `rp`.`id_puesto` = `vIdPuesto`
                AND `rp`.`activo` = 1
                AND NOT EXISTS (
                    SELECT 1
                    FROM `oferente_requisito` AS `ore`
                    WHERE `ore`.`id_oferente` = `o`.`id_oferente`
                      AND `ore`.`id_requisito` = `rp`.`id_requisito`
                      AND `ore`.`cumple` = 1
                )
          )
        ORDER BY `p`.`nombre_comple` ASC;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ObtenerRequisitosPorPuesto` (IN `pCodigoPuesto` VARCHAR(20))   BEGIN
    SELECT
        `rp`.`id_requisito` AS `IdRequisito`,
        `rp`.`nombre_requisito` AS `NombreRequisito`
    FROM `puestos` AS `p`
    INNER JOIN `requisitos_puesto` AS `rp`
        ON `rp`.`id_puesto` = `p`.`id_puesto`
    WHERE `p`.`codigo_puesto` = TRIM(`pCodigoPuesto`)
      AND `p`.`activo` = 1
      AND `rp`.`activo` = 1
    ORDER BY `rp`.`nombre_requisito` ASC;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `ValidarUsuario` (IN `pUsuario` VARCHAR(50))   BEGIN
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
    INNER JOIN `usuariorol` ur
        ON ur.`id_usuario` = u.`id_usuario`
    INNER JOIN `roles` r
        ON r.`id_rol` = ur.`id_rol`
    WHERE LOWER(u.`usuario`) = LOWER(TRIM(`pUsuario`))
    ORDER BY r.`id_rol` ASC
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
(1, 'CON-0001', '2026-01-05', 'Contratación de la coordinadora de Recursos Humanos.', 1, 2, '2026-01-05', NULL, 1),
(2, 'CON-0002', '2026-01-10', 'Contratación del director médico.', 2, NULL, '2026-01-10', NULL, 1),
(3, 'CON-0003', '2026-02-02', 'Contratación de médica general para consulta externa.', 3, 2, '2026-02-02', NULL, 1),
(4, 'CON-0004', '2026-02-15', 'Contratación de enfermero profesional.', 4, 2, '2026-02-15', NULL, 1),
(5, 'AJU-0001', '2026-06-01', 'Ajuste salarial anual por evaluación satisfactoria.', 3, 2, '2026-06-01', NULL, 1),
(6, 'TRA-0001', '2026-07-01', 'Traslado del empleado al servicio de consulta general.', 3, 2, '2026-07-01', NULL, 1),
(14, 'CON-12', '2026-07-21', 'Contratación de empleado', 12, NULL, '2026-07-21', NULL, 1),
(15, 'CON-13', '2026-07-21', 'Contratación de empleado', 13, NULL, '2026-07-21', NULL, 1),
(16, 'CON-14', '2026-07-21', 'Contratación de empleado', 14, NULL, '2026-07-21', NULL, 1),
(17, 'CON-15', '2026-07-21', 'Contratación de empleado', 15, NULL, '2026-07-21', NULL, 1),
(18, 'CON-16', '2026-07-21', 'Contratación de empleado', 16, NULL, '2026-07-21', NULL, 1),
(19, 'CON-17', '2026-07-21', 'Contratación de empleado', 17, NULL, '2026-07-21', NULL, 1),
(20, 'CON-18', '2026-07-21', 'Contratación de empleado', 18, NULL, '2026-07-21', NULL, 1);

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
(1, 'AREA-RH', 'Recursos Humanos', 1, 1),
(2, 'AREA-DM', 'Dirección Médica', 2, 1),
(3, 'AREA-CG', 'Consulta General', 3, 1),
(4, 'AREA-ENF', 'Enfermería', 4, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacoras`
--

CREATE TABLE `bitacoras` (
  `id_bitacoras` int(11) NOT NULL,
  `fecha_bitacora` datetime NOT NULL DEFAULT current_timestamp(),
  `id_usuario` int(11) NOT NULL,
  `accion` varchar(50) NOT NULL,
  `descripcionAccion` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ;

--
-- Volcado de datos para la tabla `bitacoras`
--

INSERT INTO `bitacoras` (`id_bitacoras`, `fecha_bitacora`, `id_usuario`, `accion`, `descripcionAccion`) VALUES
(1, '2026-07-20 23:28:39', 2, 'Crear AUT3', '{\"mensaje\": \"Se registra oferente publico para puesto\", \"registro\": {\"idPersona\": \"13\", \"idOferente\": \"13\", \"idPuesto\": \"2\", \"idOferentePuesto\": \"9\", \"identificacion\": \"305280498\", \"tipoIdentificacion\": \"CedulaIdentidad\", \"nombreCompleto\": \"Antony Cervantes Calderon\", \"codigoPuesto\": \"RH-COOR\", \"nombrePuesto\": \"Coordinador de Recursos Humanos\", \"correos\": [\"antonny22c.c@gmail.com\"], \"telefonos\": [\"63368175\"], \"curriculum\": {\"ruta\": \"aut3-curriculums/aut3_20260721_052839_aaf495e007cf09e9.pdf\", \"nombre\": \"Resumen_Antony_Cervantes.pdf\", \"mime\": \"application/pdf\", \"tamanio\": \"207583\"}}}');

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
(8, 'Belén', 4),
(1, 'Central', 1),
(3, 'Central', 2),
(5, 'Central', 3),
(7, 'Central', 4),
(11, 'Central', 6),
(13, 'Central', 7),
(2, 'Escazú', 1),
(12, 'Esparza', 6),
(6, 'La Unión', 3),
(9, 'Liberia', 5),
(10, 'Nicoya', 5),
(14, 'Pococí', 7),
(4, 'San Ramón', 2);

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
(1, 'SM-001', 'Servicios Médicos SA'),
(2, 'LAB-001', 'Laboratorios Clínicos del Este'),
(3, 'FAR-001', 'Farmacia Central Cartago'),
(4, 'SEG-001', 'Aseguradora Vida y Salud'),
(5, 'INS-001', 'Insumos Hospitalarios Costa Rica'),
(6, 'TEC-001', 'Tecnología Médica del Valle');

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
(1, 'CON-2026-001', 'Concurso para Médico General', '2026-07-01', '2026-08-15', 'Vigente'),
(2, 'CON-2026-002', 'Concurso para Enfermero Profesional', '2026-07-05', '2026-08-20', 'Vigente'),
(3, 'CON-2026-003', 'Concurso para Técnico de Laboratorio', '2026-07-10', '2026-08-25', 'Vigente'),
(4, 'CON-2026-004', 'Concurso para Asistente Administrativo', '2026-07-12', '2026-08-10', 'Vigente'),
(5, 'CON-2026-005', 'Concurso para Técnico en Farmacia', '2026-07-15', '2026-08-30', 'Vigente'),
(6, 'CON-2026-006', 'Concurso para Coordinador de Recursos Humanos', '2026-05-01', '2026-06-15', 'Vencido'),
(7, 'CON-2026-007', 'Concurso para Auxiliar de Limpieza', '2026-04-01', '2026-05-10', 'Vencido'),
(8, 'CON-2026-008', 'Concurso para Director Médico', '2026-07-18', '2026-09-01', 'Vigente');

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
(5, 'Alajuela', 3),
(18, 'Cañas Dulces', 9),
(1, 'Carmen', 1),
(2, 'Catedral', 1),
(22, 'Chacarita', 11),
(3, 'Escazú', 2),
(23, 'Espíritu Santo', 12),
(27, 'Guápiles', 14),
(13, 'Heredia', 7),
(28, 'Jiménez', 14),
(16, 'La Ribera', 8),
(17, 'Liberia', 9),
(25, 'Limón', 13),
(20, 'Mansión', 10),
(14, 'Mercedes', 7),
(19, 'Nicoya', 10),
(10, 'Occidental', 5),
(9, 'Oriental', 5),
(21, 'Puntarenas', 11),
(15, 'San Antonio', 8),
(12, 'San Diego', 6),
(6, 'San José', 3),
(24, 'San Juan Grande', 12),
(4, 'San Rafael', 2),
(7, 'San Ramón', 4),
(8, 'Santiago', 4),
(11, 'Tres Ríos', 6),
(26, 'Valle La Estrella', 13);

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
(1, 'EMP-2026-0001', 1, '2026-01-05', 'Ana Sofía Vargas Rojas', '117650432', 'CedulaIdentidad', 2, '2026-01-05', 'activo', NULL, NULL),
(2, 'EMP-2026-0002', 2, '2026-01-10', 'Luis Fernando Mora Castro', '304980721', 'CedulaIdentidad', 1, '2026-01-10', 'activo', NULL, NULL),
(3, 'EMP-2026-0003', 3, '2026-02-02', 'Valeria Jiménez Araya', '109870654', 'CedulaIdentidad', 3, '2026-02-02', 'activo', NULL, NULL),
(4, 'EMP-2026-0004', 4, '2026-02-15', 'Andrés Mauricio Hernández López', '155812345678', 'DIMEX', 4, '2026-02-15', 'activo', NULL, NULL),
(12, 'EMP-20260721020528', 9, '2026-07-21', 'Camila Andrea Soto Peña', '155898765432', 'DIMEX', 6, '2026-07-21', 'activo', NULL, NULL),
(13, 'EMP-20260721020631', 5, '2026-07-21', 'Daniela María Solano Vega', '702340981', 'CedulaIdentidad', 6, '2026-07-21', 'activo', NULL, NULL),
(14, 'EMP-20260721021150', 12, '2026-07-21', 'Carlos Andrés Mora Solano', '118760945', 'CedulaIdentidad', 2, '2026-07-21', 'activo', NULL, NULL),
(15, 'EMP-20260721021648', 10, '2026-07-21', 'Ricardo Antonio López Marín', 'P87654321', 'Pasaporte', 7, '2026-07-21', 'activo', NULL, NULL),
(16, 'EMP-20260721021937', 8, '2026-07-21', 'José Pablo Quesada Brenes', '402780123', 'CedulaIdentidad', 5, '2026-07-21', 'activo', NULL, NULL),
(17, 'EMP-20260721022002', 6, '2026-07-21', 'Gabriel Esteban Rojas Méndez', 'P12345678', 'Pasaporte', 3, '2026-07-21', 'activo', NULL, NULL),
(18, 'EMP-20260721022110', 7, '2026-07-21', 'Natalia Fernanda Chaves Mora', '205670432', 'CedulaIdentidad', 4, '2026-07-21', 'activo', NULL, NULL);

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
(1, 5, 1, '2026-07-15 09:00:00', 'Realizada'),
(2, 6, 2, '2026-07-16 10:30:00', 'Realizada'),
(3, 7, 4, '2026-07-18 14:00:00', 'Realizada'),
(4, 8, 2, '2026-07-22 08:30:00', 'Pendiente'),
(5, 9, 1, '2026-07-23 11:00:00', 'Pendiente'),
(6, 10, 2, '2026-07-24 13:30:00', 'Pendiente'),
(7, 11, 1, '2026-07-27 09:30:00', 'Pendiente'),
(8, 12, 1, '2026-07-28 15:00:00', 'Pendiente');

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
(1, 1, 'Centro Médico Los Ángeles', 'Analista de Recursos Humanos', '2015-01-05', '2020-12-18'),
(2, 1, 'Clínica Santa Elena', 'Coordinadora de Personal', '2021-01-04', '2025-11-28'),
(3, 2, 'Hospital Regional Cartago', 'Médico General', '2014-01-06', '2021-12-30'),
(4, 2, 'Clínica Integral Central', 'Jefe Médico', '2022-01-03', '2025-11-30'),
(5, 3, 'Área de Salud El Guarco', 'Médico General', '2021-01-04', '2025-12-20'),
(6, 4, 'Hospital Metropolitano', 'Enfermero de Emergencias', '2015-01-05', '2025-12-18'),
(7, 5, 'Consultorio Médico La Sabana', 'Asistente Administrativa', '2020-01-06', '2025-06-30'),
(8, 6, 'Clínica San Rafael', 'Médico de Consulta Externa', '2020-01-06', '2026-06-30'),
(9, 7, 'Hospital Monseñor Sanabria', 'Enfermera Profesional', '2021-02-01', '2026-06-28'),
(10, 8, 'Laboratorio Bioanálisis', 'Técnico de Laboratorio', '2016-01-04', '2026-06-30'),
(11, 9, 'Servicios Administrativos del Sur', 'Asistente Administrativa', '2018-01-08', '2026-06-30'),
(12, 10, 'Farmacia La Salud', 'Técnico en Farmacia', '2011-01-03', '2026-06-25'),
(13, 11, 'Clínica Familiar Cartago', 'Recepcionista', '2022-01-03', '2026-06-30'),
(14, 12, 'Hospital del Valle', 'Analista de Recursos Humanos', '2016-01-04', '2026-06-30');

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
(1, 'UCR', 'Universidad de Costa Rica'),
(2, 'UNA', 'Universidad Nacional de Costa Rica'),
(3, 'TEC', 'Instituto Tecnológico de Costa Rica'),
(4, 'UNED', 'Universidad Estatal a Distancia'),
(5, 'UTN', 'Universidad Técnica Nacional'),
(6, 'CUC', 'Colegio Universitario de Cartago'),
(7, 'INA', 'Instituto Nacional de Aprendizaje'),
(8, 'UCIMED', 'Universidad de Ciencias Médicas'),
(9, 'UH', 'Universidad Hispanoamericana'),
(10, 'ULATINA', 'Universidad Latina de Costa Rica');

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
(1, 1, '2025-12-01 09:00:00'),
(2, 2, '2025-12-02 09:15:00'),
(3, 3, '2026-01-05 10:20:00'),
(4, 4, '2026-01-08 11:00:00'),
(5, 5, '2026-07-02 08:30:00'),
(6, 6, '2026-07-03 09:10:00'),
(7, 7, '2026-07-05 13:45:00'),
(8, 8, '2026-07-07 15:20:00'),
(9, 9, '2026-07-09 10:05:00'),
(10, 10, '2026-07-11 14:35:00'),
(11, 11, '2026-07-14 08:50:00'),
(12, 12, '2026-07-18 16:15:00'),
(13, 13, '2026-07-20 23:28:39');

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
(1, 5, 4, '2026-07-02 08:35:00'),
(2, 5, 6, '2026-07-02 08:40:00'),
(3, 6, 1, '2026-07-03 09:15:00'),
(4, 6, 8, '2026-07-03 09:20:00'),
(5, 7, 2, '2026-07-05 13:50:00'),
(6, 8, 3, '2026-07-07 15:25:00'),
(7, 9, 4, '2026-07-09 10:10:00'),
(8, 10, 5, '2026-07-11 14:40:00'),
(9, 11, 4, '2026-07-14 08:55:00'),
(10, 12, 6, '2026-07-18 16:20:00'),
(11, 12, 4, '2026-07-18 16:25:00');

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
(1, 1, 'ana.vargas@correo.test'),
(2, 2, 'luis.mora@correo.test'),
(3, 3, 'valeria.jimenez@correo.test'),
(4, 4, 'andres.hernandez@correo.test'),
(5, 5, 'daniela.solano@correo.test'),
(6, 5, 'daniela.solano.laboral@correo.test'),
(7, 6, 'gabriel.rojas@correo.test'),
(8, 7, 'natalia.chaves@correo.test'),
(9, 8, 'jose.quesada@correo.test'),
(10, 9, 'camila.soto@correo.test'),
(11, 10, 'ricardo.lopez@correo.test'),
(12, 11, 'maria.arce@correo.test'),
(13, 12, 'carlos.mora@correo.test'),
(14, 13, 'antonny22c.c@gmail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oferente_puesto`
--

CREATE TABLE `oferente_puesto` (
  `id_oferente_puesto` int(11) NOT NULL,
  `id_oferente` int(11) NOT NULL,
  `id_puesto` int(11) NOT NULL,
  `fecha_postulacion` datetime NOT NULL DEFAULT current_timestamp(),
  `estado` enum('Postulado','Cancelado') NOT NULL DEFAULT 'Postulado',
  `ruta_curriculum` varchar(500) NOT NULL,
  `nombre_curriculum` varchar(255) NOT NULL,
  `mime_curriculum` varchar(120) NOT NULL,
  `tamanio_curriculum` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `oferente_puesto`
--

INSERT INTO `oferente_puesto` (`id_oferente_puesto`, `id_oferente`, `id_puesto`, `fecha_postulacion`, `estado`, `ruta_curriculum`, `nombre_curriculum`, `mime_curriculum`, `tamanio_curriculum`) VALUES
(1, 5, 6, '2026-07-02 08:45:00', 'Postulado', 'uploads/curriculum/cv_daniela_solano.pdf', 'cv_daniela_solano.pdf', 'application/pdf', 184320),
(2, 6, 3, '2026-07-03 09:25:00', 'Postulado', 'uploads/curriculum/cv_gabriel_rojas.pdf', 'cv_gabriel_rojas.pdf', 'application/pdf', 215040),
(3, 7, 4, '2026-07-05 13:55:00', 'Postulado', 'uploads/curriculum/cv_natalia_chaves.pdf', 'cv_natalia_chaves.pdf', 'application/pdf', 176128),
(4, 8, 5, '2026-07-07 15:30:00', 'Postulado', 'uploads/curriculum/cv_jose_quesada.pdf', 'cv_jose_quesada.pdf', 'application/pdf', 194560),
(5, 9, 6, '2026-07-09 10:15:00', 'Postulado', 'uploads/curriculum/cv_camila_soto.pdf', 'cv_camila_soto.pdf', 'application/pdf', 168960),
(6, 10, 7, '2026-07-11 14:45:00', 'Postulado', 'uploads/curriculum/cv_ricardo_lopez.pdf', 'cv_ricardo_lopez.pdf', 'application/pdf', 205824),
(7, 11, 6, '2026-07-14 09:00:00', 'Postulado', 'uploads/curriculum/cv_maria_arce.pdf', 'cv_maria_arce.pdf', 'application/pdf', 157696),
(8, 12, 2, '2026-07-18 16:30:00', 'Postulado', 'uploads/curriculum/cv_carlos_mora.pdf', 'cv_carlos_mora.pdf', 'application/pdf', 221184),
(9, 13, 2, '2026-07-20 23:28:39', 'Postulado', 'aut3-curriculums/aut3_20260721_052839_aaf495e007cf09e9.pdf', 'Resumen_Antony_Cervantes.pdf', 'application/pdf', 207583);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oferente_requisito`
--

CREATE TABLE `oferente_requisito` (
  `id_oferente` int(11) NOT NULL,
  `id_requisito` int(11) NOT NULL,
  `cumple` tinyint(1) NOT NULL DEFAULT 1,
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `oferente_requisito`
--

INSERT INTO `oferente_requisito` (`id_oferente`, `id_requisito`, `cumple`, `fecha_registro`) VALUES
(5, 15, 1, '2026-07-20 15:38:07'),
(5, 16, 1, '2026-07-20 15:38:07'),
(6, 7, 1, '2026-07-20 15:38:07'),
(6, 8, 1, '2026-07-20 15:38:07'),
(6, 9, 1, '2026-07-20 15:38:07'),
(7, 10, 1, '2026-07-20 15:38:07'),
(7, 11, 1, '2026-07-20 15:38:07'),
(7, 12, 1, '2026-07-20 15:38:07'),
(8, 13, 1, '2026-07-20 15:38:07'),
(8, 14, 1, '2026-07-20 15:38:07'),
(9, 15, 1, '2026-07-20 15:38:07'),
(9, 16, 1, '2026-07-20 15:38:07'),
(10, 17, 1, '2026-07-20 15:38:07'),
(10, 18, 1, '2026-07-20 15:38:07'),
(11, 15, 1, '2026-07-20 15:38:07'),
(11, 16, 1, '2026-07-20 15:38:07'),
(12, 4, 1, '2026-07-20 15:38:07'),
(12, 5, 1, '2026-07-20 15:38:07'),
(12, 6, 1, '2026-07-20 15:38:07');

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
(1, 1, '88881001'),
(2, 2, '88881002'),
(3, 3, '88881003'),
(4, 4, '88881004'),
(5, 5, '88881005'),
(6, 5, '22221005'),
(7, 6, '88881006'),
(8, 7, '88881007'),
(9, 8, '88881008'),
(10, 9, '88881009'),
(11, 10, '88881010'),
(12, 11, '88881011'),
(13, 12, '88881012'),
(14, 13, '63368175');

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
(1, 'Inicio', '2026-07-20 08:00:00', NULL, 1),
(2, 'Usuarios', '2026-07-20 08:00:00', NULL, 1),
(3, 'Roles', '2026-07-20 08:00:00', NULL, 1),
(4, 'Pantallas', '2026-07-20 08:00:00', NULL, 1),
(5, 'Parámetros', '2026-07-20 08:00:00', NULL, 1),
(6, 'Bitácora', '2026-07-20 08:00:00', NULL, 1),
(7, 'Cargar Datos de Ubicación', '2026-07-20 08:00:00', NULL, 1),
(8, 'Compañías', '2026-07-20 08:00:00', NULL, 1),
(9, 'Oferentes', '2026-07-20 08:00:00', NULL, 1),
(10, 'Concursos', '2026-07-20 08:00:00', NULL, 1),
(11, 'Agendar Entrevistas', '2026-07-20 08:00:00', NULL, 1),
(12, 'Contratar Empleado', '2026-07-20 08:00:00', NULL, 1),
(13, 'Puestos', '2026-07-20 08:00:00', NULL, 1),
(14, 'Áreas', '2026-07-20 08:00:00', NULL, 1),
(15, 'Acciones de Personal', '2026-07-20 08:00:00', NULL, 1),
(16, 'Instituciones Educativas', '2026-07-20 08:00:00', NULL, 1),
(17, 'Listado de Puestos Activos', '2026-07-20 08:00:00', NULL, 1);

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
(1, 'LONGITUD_USUARIO', '50'),
(2, 'LONGITUD_NOMBRE_ROL', '40'),
(3, 'LONGITUD_NOMBRE_PANTALLA', '100'),
(4, 'LONGITUD_COD_AREA', '20'),
(5, 'LONGITUD_NOMBRE_AREA', '100'),
(6, 'LONGITUD_COD_COMPANIA', '50'),
(7, 'LONGITUD_NOMBRE_COMPANIA', '150'),
(8, 'LONGITUD_NOMBRE_PUESTO', '150'),
(9, 'LONGITUD_NOMBRE_INSTITUCION', '150'),
(10, 'MAXIMO_REGISTROS_PAGINA', '10'),
(11, 'MAXIMO_REGISTROS_BITACORA', '100'),
(12, 'INTENTOS_MAXIMOS_LOGIN', '3');

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
(1, '117650432', 'CedulaIdentidad', 'Ana Sofía Vargas Rojas', '1992-04-18', 'Empleado'),
(2, '304980721', 'CedulaIdentidad', 'Luis Fernando Mora Castro', '1988-09-03', 'Empleado'),
(3, '109870654', 'CedulaIdentidad', 'Valeria Jiménez Araya', '1995-12-11', 'Empleado'),
(4, '155812345678', 'DIMEX', 'Andrés Mauricio Hernández López', '1990-06-25', 'Empleado'),
(5, '702340981', 'CedulaIdentidad', 'Daniela María Solano Vega', '1998-02-14', 'Oferente'),
(6, 'P12345678', 'Pasaporte', 'Gabriel Esteban Rojas Méndez', '1994-07-30', 'Oferente'),
(7, '205670432', 'CedulaIdentidad', 'Natalia Fernanda Chaves Mora', '1997-10-09', 'Oferente'),
(8, '402780123', 'CedulaIdentidad', 'José Pablo Quesada Brenes', '1993-01-22', 'Oferente'),
(9, '155898765432', 'DIMEX', 'Camila Andrea Soto Peña', '1996-05-16', 'Oferente'),
(10, 'P87654321', 'Pasaporte', 'Ricardo Antonio López Marín', '1989-11-28', 'Oferente'),
(11, '603450987', 'CedulaIdentidad', 'María José Arce Salazar', '2000-03-07', 'Oferente'),
(12, '118760945', 'CedulaIdentidad', 'Carlos Andrés Mora Solano', '1991-08-19', 'Oferente'),
(13, '305280498', 'CedulaIdentidad', 'Antony Cervantes Calderon', '2000-11-12', 'Oferente');

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
(1, 1, 2, 'Bachillerato en Administración de Recursos Humanos', '2010-02-01', '2014-12-15'),
(2, 1, 4, 'Licenciatura en Gestión del Talento Humano', '2015-02-01', '2017-12-10'),
(3, 2, 1, 'Licenciatura en Medicina y Cirugía', '2007-02-01', '2013-12-15'),
(4, 2, 8, 'Maestría en Administración de Servicios de Salud', '2015-02-01', '2017-11-30'),
(5, 3, 8, 'Licenciatura en Medicina y Cirugía', '2014-01-15', '2020-12-10'),
(6, 4, 9, 'Licenciatura en Enfermería', '2009-02-01', '2014-12-12'),
(7, 5, 6, 'Diplomado en Administración de Empresas', '2017-02-01', '2019-12-10'),
(8, 6, 1, 'Licenciatura en Medicina y Cirugía', '2013-02-01', '2019-12-15'),
(9, 7, 8, 'Licenciatura en Enfermería', '2015-02-01', '2020-12-12'),
(10, 8, 3, 'Diplomado en Laboratorio Clínico', '2012-02-01', '2015-12-10'),
(11, 9, 5, 'Diplomado en Asistencia Administrativa', '2015-01-15', '2017-12-08'),
(12, 10, 7, 'Técnico en Farmacia', '2008-02-01', '2010-12-10'),
(13, 11, 6, 'Diplomado en Administración de Empresas', '2019-02-01', '2021-12-10'),
(14, 12, 2, 'Bachillerato en Recursos Humanos', '2011-02-01', '2015-12-10');

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
(5, 'Guanacaste'),
(4, 'Heredia'),
(7, 'Limón'),
(6, 'Puntarenas'),
(1, 'San José');

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
(1, 'DIR-MED', 'Director Médico', 2200000.00, NULL, '2026-01-10 08:00:00', NULL, 1),
(2, 'RH-COOR', 'Coordinador de Recursos Humanos', 1200000.00, NULL, '2026-01-10 08:05:00', NULL, 1),
(3, 'MED-GEN', 'Médico General', 1350000.00, 1, '2026-01-10 08:10:00', NULL, 1),
(4, 'ENF-PRO', 'Enfermero Profesional', 950000.00, 1, '2026-01-10 08:15:00', NULL, 1),
(5, 'LAB-TEC', 'Técnico de Laboratorio', 780000.00, 1, '2026-01-10 08:20:00', NULL, 1),
(6, 'ADM-ASI', 'Asistente Administrativo', 650000.00, 2, '2026-01-10 08:25:00', NULL, 1),
(7, 'FAR-TEC', 'Técnico en Farmacia', 720000.00, 1, '2026-01-10 08:30:00', NULL, 1),
(8, 'LIM-AUX', 'Auxiliar de Limpieza', 480000.00, 6, '2026-01-10 08:35:00', '2026-07-01 09:00:00', 0);

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
(1, 1, 'Licenciatura en Medicina y Cirugía', '2026-01-10 09:00:00', NULL, 1),
(2, 1, 'Incorporación vigente al Colegio de Médicos', '2026-01-10 09:01:00', NULL, 1),
(3, 1, 'Cinco años de experiencia en gestión clínica', '2026-01-10 09:02:00', NULL, 1),
(4, 2, 'Bachillerato en Recursos Humanos', '2026-01-10 09:03:00', NULL, 1),
(5, 2, 'Tres años de experiencia en reclutamiento', '2026-01-10 09:04:00', NULL, 1),
(6, 2, 'Conocimiento de legislación laboral costarricense', '2026-01-10 09:05:00', NULL, 1),
(7, 3, 'Licenciatura en Medicina y Cirugía', '2026-01-10 09:06:00', NULL, 1),
(8, 3, 'Incorporación vigente al Colegio de Médicos', '2026-01-10 09:07:00', NULL, 1),
(9, 3, 'Disponibilidad para turnos rotativos', '2026-01-10 09:08:00', NULL, 1),
(10, 4, 'Licenciatura en Enfermería', '2026-01-10 09:09:00', NULL, 1),
(11, 4, 'Incorporación vigente al Colegio de Enfermeras', '2026-01-10 09:10:00', NULL, 1),
(12, 4, 'Certificación vigente en soporte vital básico', '2026-01-10 09:11:00', NULL, 1),
(13, 5, 'Diplomado en Laboratorio Clínico', '2026-01-10 09:12:00', NULL, 1),
(14, 5, 'Experiencia en manejo de muestras biológicas', '2026-01-10 09:13:00', NULL, 1),
(15, 6, 'Bachillerato en Educación Media', '2026-01-10 09:14:00', NULL, 1),
(16, 6, 'Manejo de herramientas de oficina', '2026-01-10 09:15:00', NULL, 1),
(17, 7, 'Técnico en Farmacia', '2026-01-10 09:16:00', NULL, 1),
(18, 7, 'Conocimiento de control de inventarios', '2026-01-10 09:17:00', NULL, 1),
(19, 8, 'Experiencia en limpieza hospitalaria', '2026-01-10 09:18:00', '2026-07-01 09:00:00', 0);

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
(2, 'Reclutador de personal');

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
(1, 9),
(1, 10),
(1, 11),
(1, 12),
(1, 13),
(1, 14),
(1, 15),
(1, 16),
(1, 17),
(2, 1),
(2, 9),
(2, 10),
(2, 11),
(2, 12),
(2, 13),
(2, 14),
(2, 15),
(2, 16),
(2, 17);

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
(1, 1),
(3, 1);

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
(1, 'Admin', 'GCM:A7BgGuXsJmU/wr6FOhkvQQBjIKE+7eIK6Jz3NSowyehGpNypw9I=', 1, '2026-07-20 14:35:40', '2026-07-21 01:39:43', 'Antony Cervantes Calderon', 'antony22c.c@gmail.com', 'Activo', 0),
(2, 'AUT_PUBLICO', '5b8f2a74c4a3a21f8d9eb59ccd343bbf139b286335ef84ec103564035cab0e9a', 0, '2026-07-20 16:07:21', NULL, 'Usuario tecnico publico AUT3', NULL, 'Inactivo', 0),
(3, 'Admin2', 'GCM:1tJ7hlA1EPkHjF/2kpsdiXFaexKVW/O1xWtEwB7CwY8g/JxgvlY=', 0, '2026-07-20 23:48:33', '2026-07-20 23:48:13', 'Roberto ', 'adsas@sa.com', 'Bloqueado', 3);

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
-- Indices de la tabla `oferente_puesto`
--
ALTER TABLE `oferente_puesto`
  ADD PRIMARY KEY (`id_oferente_puesto`),
  ADD UNIQUE KEY `uq_oferente_puesto` (`id_oferente`,`id_puesto`),
  ADD KEY `idx_oferente_puesto_oferente` (`id_oferente`),
  ADD KEY `idx_oferente_puesto_puesto` (`id_puesto`);

--
-- Indices de la tabla `oferente_requisito`
--
ALTER TABLE `oferente_requisito`
  ADD PRIMARY KEY (`id_oferente`,`id_requisito`),
  ADD KEY `idx_oferente_requisito_requisito` (`id_requisito`);

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
  MODIFY `id_accion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `admin_area`
--
ALTER TABLE `admin_area`
  MODIFY `id_area` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `bitacoras`
--
ALTER TABLE `bitacoras`
  MODIFY `id_bitacoras` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `canton`
--
ALTER TABLE `canton`
  MODIFY `id_canton` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `companias`
--
ALTER TABLE `companias`
  MODIFY `id_compania` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `concursos`
--
ALTER TABLE `concursos`
  MODIFY `id_concursos` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `distrito`
--
ALTER TABLE `distrito`
  MODIFY `id_distrito` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `id_empleado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de la tabla `entrevistas`
--
ALTER TABLE `entrevistas`
  MODIFY `id_entrevista` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `experiencia_laboral`
--
ALTER TABLE `experiencia_laboral`
  MODIFY `id_experiencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `institu_educa`
--
ALTER TABLE `institu_educa`
  MODIFY `id_insti_edu` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `oferentes`
--
ALTER TABLE `oferentes`
  MODIFY `id_oferente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `oferente_concur`
--
ALTER TABLE `oferente_concur`
  MODIFY `id_of_concurso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `oferente_correo`
--
ALTER TABLE `oferente_correo`
  MODIFY `id_of_correo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `oferente_puesto`
--
ALTER TABLE `oferente_puesto`
  MODIFY `id_oferente_puesto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `oferente_telf`
--
ALTER TABLE `oferente_telf`
  MODIFY `id_of_telefono` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `pantallas`
--
ALTER TABLE `pantallas`
  MODIFY `id_pantalla` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `parametros`
--
ALTER TABLE `parametros`
  MODIFY `id_parametro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `personas`
--
ALTER TABLE `personas`
  MODIFY `id_persona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `prepara_academica`
--
ALTER TABLE `prepara_academica`
  MODIFY `id_pre_academica` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `provincias`
--
ALTER TABLE `provincias`
  MODIFY `id_provincia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `puestos`
--
ALTER TABLE `puestos`
  MODIFY `id_puesto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `requisitos_puesto`
--
ALTER TABLE `requisitos_puesto`
  MODIFY `id_requisito` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
-- Filtros para la tabla `bitacoras`
--
ALTER TABLE `bitacoras`
  ADD CONSTRAINT `bitacoras_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `fk_bitacoras_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `canton`
--
ALTER TABLE `canton`
  ADD CONSTRAINT `canton_ibfk_1` FOREIGN KEY (`id_provincia`) REFERENCES `provincias` (`id_provincia`);

--
-- Filtros para la tabla `distrito`
--
ALTER TABLE `distrito`
  ADD CONSTRAINT `distrito_ibfk_1` FOREIGN KEY (`id_canton`) REFERENCES `canton` (`id_canton`);

--
-- Filtros para la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD CONSTRAINT `empleados_ibfk_1` FOREIGN KEY (`id_oferente`) REFERENCES `oferentes` (`id_oferente`),
  ADD CONSTRAINT `empleados_ibfk_2` FOREIGN KEY (`id_puesto`) REFERENCES `puestos` (`id_puesto`),
  ADD CONSTRAINT `empleados_ibfk_3` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `entrevistas`
--
ALTER TABLE `entrevistas`
  ADD CONSTRAINT `entrevistas_ibfk_1` FOREIGN KEY (`id_oferente`) REFERENCES `oferentes` (`id_oferente`),
  ADD CONSTRAINT `entrevistas_ibfk_2` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`);

--
-- Filtros para la tabla `experiencia_laboral`
--
ALTER TABLE `experiencia_laboral`
  ADD CONSTRAINT `experiencia_laboral_ibfk_1` FOREIGN KEY (`id_oferente`) REFERENCES `oferentes` (`id_oferente`);

--
-- Filtros para la tabla `oferentes`
--
ALTER TABLE `oferentes`
  ADD CONSTRAINT `oferentes_ibfk_1` FOREIGN KEY (`id_persona`) REFERENCES `personas` (`id_persona`);

--
-- Filtros para la tabla `oferente_concur`
--
ALTER TABLE `oferente_concur`
  ADD CONSTRAINT `oferente_concur_ibfk_1` FOREIGN KEY (`id_oferente`) REFERENCES `oferentes` (`id_oferente`),
  ADD CONSTRAINT `oferente_concur_ibfk_2` FOREIGN KEY (`id_concursos`) REFERENCES `concursos` (`id_concursos`);

--
-- Filtros para la tabla `oferente_correo`
--
ALTER TABLE `oferente_correo`
  ADD CONSTRAINT `oferente_correo_ibfk_1` FOREIGN KEY (`id_oferente`) REFERENCES `oferentes` (`id_oferente`);

--
-- Filtros para la tabla `oferente_puesto`
--
ALTER TABLE `oferente_puesto`
  ADD CONSTRAINT `oferente_puesto_ibfk_1` FOREIGN KEY (`id_oferente`) REFERENCES `oferentes` (`id_oferente`),
  ADD CONSTRAINT `oferente_puesto_ibfk_2` FOREIGN KEY (`id_puesto`) REFERENCES `puestos` (`id_puesto`);

--
-- Filtros para la tabla `oferente_requisito`
--
ALTER TABLE `oferente_requisito`
  ADD CONSTRAINT `fk_oferente_requisito_oferente` FOREIGN KEY (`id_oferente`) REFERENCES `oferentes` (`id_oferente`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_oferente_requisito_requisito` FOREIGN KEY (`id_requisito`) REFERENCES `requisitos_puesto` (`id_requisito`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `oferente_telf`
--
ALTER TABLE `oferente_telf`
  ADD CONSTRAINT `oferente_telf_ibfk_1` FOREIGN KEY (`id_oferente`) REFERENCES `oferentes` (`id_oferente`);

--
-- Filtros para la tabla `prepara_academica`
--
ALTER TABLE `prepara_academica`
  ADD CONSTRAINT `prepara_academica_ibfk_1` FOREIGN KEY (`id_oferente`) REFERENCES `oferentes` (`id_oferente`),
  ADD CONSTRAINT `prepara_academica_ibfk_2` FOREIGN KEY (`id_insti_edu`) REFERENCES `institu_educa` (`id_insti_edu`);

--
-- Filtros para la tabla `puestos`
--
ALTER TABLE `puestos`
  ADD CONSTRAINT `puestos_ibfk_1` FOREIGN KEY (`id_puesto_jefac`) REFERENCES `puestos` (`id_puesto`);

--
-- Filtros para la tabla `requisitos_puesto`
--
ALTER TABLE `requisitos_puesto`
  ADD CONSTRAINT `requisitos_puesto_ibfk_1` FOREIGN KEY (`id_puesto`) REFERENCES `puestos` (`id_puesto`);

--
-- Filtros para la tabla `rolpantalla`
--
ALTER TABLE `rolpantalla`
  ADD CONSTRAINT `FK_RolPantalla_Pantalla` FOREIGN KEY (`id_pantalla`) REFERENCES `pantallas` (`id_pantalla`),
  ADD CONSTRAINT `FK_RolPantalla_Rol` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`);

--
-- Filtros para la tabla `usuariorol`
--
ALTER TABLE `usuariorol`
  ADD CONSTRAINT `usuariorol_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `usuariorol_ibfk_2` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
