module Storage.Queries.Issue.IssueCategory where

import Database.Beam.Postgres (Postgres)
import Domain.Types.Issue.IssueCategory
import qualified Domain.Types.Issue.IssueCategory as DomainIC
import Domain.Types.Issue.IssueTranslation as DomainIT
import qualified EulerHS.KVConnector.Flow as KV
import qualified EulerHS.Language as L
import qualified Kernel.Beam.Types as KBT
import Kernel.External.Types (Language)
import Kernel.Prelude
import Kernel.Types.Id
import Lib.Utils (setMeshConfig)
import qualified Sequelize as Se
import qualified Storage.Beam.Issue.IssueCategory as BeamIC
import qualified Storage.Beam.Issue.IssueTranslation as BeamIT
import qualified Storage.Queries.Issue.IssueTranslation as QueriesIT

-- fullCategoryTable ::
--   Language ->
--   From
--     ( Table IssueCategoryT
--         :& MbTable IssueTranslationT
--     )
-- fullCategoryTable language =
--   table @IssueCategoryT
--     `leftJoin` table @IssueTranslationT
--       `Esq.on` ( \(category :& translation) ->
--                    just (category ^. IssueCategoryCategory) ==. translation ?. IssueTranslationSentence
--                      &&. translation ?. IssueTranslationLanguage ==. just (val language)
--                )

-- findAllByLanguage :: Transactionable m => Language -> m [(IssueCategory, Maybe IssueTranslation)]
-- findAllByLanguage language = Esq.findAll $ do
--   (issueCategory :& mbIssueTranslation) <- from $ fullCategoryTable language
--   return (issueCategory, mbIssueTranslation)

findAllIssueTranslationWithSeCondition :: L.MonadFlow m => [Se.Clause Postgres BeamIT.IssueTranslationT] -> m [IssueTranslation]
findAllIssueTranslationWithSeCondition seCondition = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamIT.IssueTranslationT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> either (pure []) (QueriesIT.transformBeamIssueTranslationToDomain <$>) <$> KV.findAllWithKVConnector dbConf' updatedMeshConfig seCondition
    Nothing -> pure []

findAllIssueCategoryWithSeCondition :: L.MonadFlow m => [Se.Clause Postgres BeamIC.IssueCategoryT] -> m [IssueCategory]
findAllIssueCategoryWithSeCondition seCondition = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamIC.IssueCategoryT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> either (pure []) (transformBeamIssueCategoryToDomain <$>) <$> KV.findAllWithKVConnector dbConf' updatedMeshConfig seCondition
    Nothing -> pure []

findAllByLanguage :: L.MonadFlow m => Language -> m [(IssueCategory, Maybe IssueTranslation)]
findAllByLanguage language = do
  iTranslations <- findAllIssueTranslationWithSeCondition [Se.Is BeamIT.language $ Se.Eq language]
  let iCategorySeCondition = [Se.Is BeamIC.category $ Se.In (DomainIT.sentence <$> iTranslations)]
  iCategorys <- findAllIssueCategoryWithSeCondition iCategorySeCondition
  let dCategoriesWithTranslations = foldl' (getIssueCategoryWithTranslations iTranslations) [] iCategorys
  pure dCategoriesWithTranslations
  where
    getIssueCategoryWithTranslations iTranslations dInfosWithTranslations iCategory =
      let iTranslations' = filter (\iTranslation -> iTranslation.sentence == iCategory.category) iTranslations
       in dInfosWithTranslations <> if not (null iTranslations') then (\iTranslation'' -> (iCategory, Just iTranslation'')) <$> iTranslations' else [(iCategory, Nothing)]

-- findById :: Transactionable m => Id IssueCategory -> m (Maybe IssueCategory)
-- findById issueCategoryId = Esq.findOne $ do
--   issueCategory <- from $ table @IssueCategoryT
--   where_ $ issueCategory ^. IssueCategoryTId ==. val (toKey issueCategoryId)
--   return issueCategory

findById :: L.MonadFlow m => Id IssueCategory -> m (Maybe IssueCategory)
findById (Id issueCategoryId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamIC.IssueCategoryT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbCOnf' -> either (pure Nothing) (transformBeamIssueCategoryToDomain <$>) <$> KV.findWithKVConnector dbCOnf' updatedMeshConfig [Se.Is BeamIC.id $ Se.Eq issueCategoryId]
    Nothing -> pure Nothing

-- findByIdAndLanguage :: Transactionable m => Id IssueCategory -> Language -> m (Maybe (IssueCategory, Maybe IssueTranslation))
-- findByIdAndLanguage issueCategoryId language = Esq.findOne $ do
--   (issueCategory :& mbIssueTranslation) <- from $ fullCategoryTable language
--   where_ $ issueCategory ^. IssueCategoryTId ==. val (toKey issueCategoryId)
--   return (issueCategory, mbIssueTranslation)

findByIdAndLanguage :: L.MonadFlow m => Id IssueCategory -> Language -> m (Maybe (IssueCategory, Maybe IssueTranslation))
findByIdAndLanguage (Id issueCategoryId) language = do
  iCategory <- findAllIssueCategoryWithSeCondition [Se.Is BeamIC.id $ Se.Eq issueCategoryId]
  iTranslations <- findAllIssueTranslationWithSeCondition [Se.And [Se.Is BeamIT.language $ Se.Eq language, Se.Is BeamIT.sentence $ Se.In (DomainIC.category <$> iCategory)]]
  let dInfosWithTranslations' = foldl' (getIssueOptionsWithTranslations iTranslations) [] iCategory
      dInfosWithTranslations = headMaybe dInfosWithTranslations'
  pure dInfosWithTranslations
  where
    getIssueOptionsWithTranslations iTranslations dInfosWithTranslations iCategory =
      let iTranslations' = filter (\iTranslation -> iTranslation.sentence == iCategory.category) iTranslations
       in dInfosWithTranslations <> if not (null iTranslations') then (\iTranslation'' -> (iCategory, Just iTranslation'')) <$> iTranslations' else [(iCategory, Nothing)]

    headMaybe dInfosWithTranslations' = if null dInfosWithTranslations' then Nothing else Just (head dInfosWithTranslations')

transformBeamIssueCategoryToDomain :: BeamIC.IssueCategory -> IssueCategory
transformBeamIssueCategoryToDomain BeamIC.IssueCategoryT {..} = do
  IssueCategory
    { id = Id id,
      category = category,
      logoUrl = logoUrl
    }

transformDomainIssueCategoryToBeam :: IssueCategory -> BeamIC.IssueCategory
transformDomainIssueCategoryToBeam IssueCategory {..} =
  BeamIC.IssueCategoryT
    { BeamIC.id = getId id,
      BeamIC.category = category,
      BeamIC.logoUrl = logoUrl
    }
