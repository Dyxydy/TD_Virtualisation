
USE `myrames-prod-db`;

CREATE TABLE IF NOT EXISTS `voies` (
    `num_voie`  INT(11)     NOT NULL,
    `interdite` TINYINT(1)  NOT NULL,
    PRIMARY KEY (`num_voie`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================================================
-- TABLE : rames
-- =============================================================================
-- Représente les rames actuellement dans le centre (en attente d'affectation
-- ou en cours de maintenance). Une rame est supprimée dès qu'elle sort du dépôt.
--
-- num_serie          : identifiant unique de la rame (ex: AZ4356763), PK.
-- type_rame          : type de la rame (ex: BB7200).
-- voie               : FK vers voie.num_voie. NULL = en attente d'affectation
--                      (demande reçue, pas encore de voie assignée).
--                      UNIQUE : une voie ne peut accueillir qu'une seule rame.
-- conducteur_entrant : identifiant du conducteur auteur de la demande d'entrée.
-- =============================================================================
CREATE TABLE IF NOT EXISTS `rames` (
    `num_serie`          VARCHAR(12) NOT NULL,
    `type_rame`          VARCHAR(50) NOT NULL,
    `voie`               INT(11)     DEFAULT NULL,
    `conducteur_entrant` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`num_serie`),
    UNIQUE KEY  `uq_rame_voie` (`voie`),
    CONSTRAINT  `fk_rame_voie`
        FOREIGN KEY (`voie`)
        REFERENCES `voies` (`num_voie`)
        -- ON DELETE RESTRICT : impossible de supprimer une voie occupée
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================================================
-- TABLE : taches
-- =============================================================================
-- Représente les tâches DE MAINTENANCE RESTANTES à réaliser sur une rame.
-- Quand toutes les tâches sont supprimées, la rame est "disponible au retrait".
--
-- num_serie_rame : FK vers rames.num_serie (partie de la PK composite).
--                 CASCADE DELETE : si la rame est supprimée (sortie ou rejet),
--                 ses tâches sont automatiquement supprimées.
-- num_tache      : numéro ordinal de la tâche au sein de la rame (PK composite).
-- tache          : description textuelle de la tâche (TEXT = jusqu'à 65 535 oct).
-- =============================================================================
CREATE TABLE IF NOT EXISTS `taches` (
    `num_serie`  VARCHAR(12) NOT NULL,
    `num_tache`  INT(11)     NOT NULL,
    `tache`      TEXT        NOT NULL,
    PRIMARY KEY (`num_serie`, `num_tache`),
    CONSTRAINT `fk_tache_rame`
        FOREIGN KEY (`num_serie`)
        REFERENCES `rames` (`num_serie`)
        -- ON DELETE CASCADE : supprimer une rame supprime aussi toutes ses tâches
        ON DELETE CASCADE
        ON UPDATE CASCADE
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
