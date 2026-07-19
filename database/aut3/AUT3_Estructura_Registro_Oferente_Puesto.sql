-- Persona C - Kenneth
-- Agrega la estructura necesaria para el registro publico de AUT3.

CREATE TABLE IF NOT EXISTS `oferente_puesto` (
  `id_oferente_puesto` int(11) NOT NULL AUTO_INCREMENT,
  `id_oferente` int(11) NOT NULL,
  `id_puesto` int(11) NOT NULL,
  `fecha_postulacion` datetime NOT NULL DEFAULT current_timestamp(),
  `estado` enum('Postulado','Cancelado') NOT NULL DEFAULT 'Postulado',
  `ruta_curriculum` varchar(500) NOT NULL,
  `nombre_curriculum` varchar(255) NOT NULL,
  `mime_curriculum` varchar(120) NOT NULL,
  `tamanio_curriculum` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id_oferente_puesto`),
  UNIQUE KEY `uq_oferente_puesto` (`id_oferente`, `id_puesto`),
  KEY `idx_oferente_puesto_oferente` (`id_oferente`),
  KEY `idx_oferente_puesto_puesto` (`id_puesto`),
  CONSTRAINT `oferente_puesto_ibfk_1` FOREIGN KEY (`id_oferente`) REFERENCES `oferentes` (`id_oferente`),
  CONSTRAINT `oferente_puesto_ibfk_2` FOREIGN KEY (`id_puesto`) REFERENCES `puestos` (`id_puesto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `usuarios` (
  `usuario`,
  `contrasena`,
  `activo`,
  `fecha_modifi`,
  `fecha_access`,
  `nombre_completo`,
  `correo`,
  `estado`,
  `intentos_fallidos`
)
SELECT
  'AUT_PUBLICO',
  SHA2(CONCAT('AUT3_PUBLICO_NO_LOGIN_', UUID()), 256),
  0,
  NOW(),
  NULL,
  'Usuario tecnico publico AUT3',
  NULL,
  'Inactivo',
  0
WHERE NOT EXISTS (
  SELECT 1
  FROM `usuarios`
  WHERE `usuario` = 'AUT_PUBLICO'
);

DROP PROCEDURE IF EXISTS `sp_aut3_registrar_oferente_puesto`;

DELIMITER $$

CREATE PROCEDURE `sp_aut3_registrar_oferente_puesto` (
  IN `pTipoIdentificacion` VARCHAR(20),
  IN `pIdentificacion` VARCHAR(30),
  IN `pNombreCompleto` VARCHAR(150),
  IN `pFechaNacimiento` DATE,
  IN `pCorreosJson` LONGTEXT,
  IN `pTelefonosJson` LONGTEXT,
  IN `pCodigoPuesto` VARCHAR(20),
  IN `pRutaCurriculum` VARCHAR(500),
  IN `pNombreCurriculum` VARCHAR(255),
  IN `pMimeCurriculum` VARCHAR(120),
  IN `pTamanioCurriculum` INT UNSIGNED,
  IN `pIdUsuarioTecnico` INT
)
BEGIN
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

DELIMITER ;
