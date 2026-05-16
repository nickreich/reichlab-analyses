# Annotated Bibliography: Scoring Rules for Probabilistic Epidemiological Forecasts of Seasonal Trajectories

This annotated bibliography surveys scoring rules and forecast-evaluation metrics relevant to probabilistic epidemiological forecasts that span an entire season as full trajectories rather than as a sequence of independent horizons. The motivating problem is that operational hubs (CDC FluSight, US COVID-19 Forecast Hub, ECDC RESPICAST) currently rely on the Weighted Interval Score (WIS) and log-score applied marginally to quantile forecasts at each horizon; this rewards wide, flat "hedger" forecasts and penalizes sharp, phase-shifted forecasts that nonetheless capture epidemic shape. References below are organized into six thematic sections covering the foundations of proper scoring rules, multivariate / joint scores, trajectory-level hub evaluations, functional and shape-based metrics, decision-relevant peak-timing/peak-intensity targets, and explicit critiques or proposed alternatives.

All DOIs were verified against CrossRef on 2026-05-12. Two non-DOI works (Berndt & Clifford 1994 workshop paper; Pinson & Tastu 2013 technical report) are marked `[citation not verified]` because no CrossRef record exists; canonical URLs are provided where available.

## 1. Proper scoring rules foundations

Matheson, J. E., & Winkler, R. L. (1976). Scoring rules for continuous probability distributions. *Management Science*, *22*(10), 1087-1096. https://doi.org/10.1287/mnsc.22.10.1087

- The foundational reference for continuous-distribution scoring rules, predating and informing Gneiting & Raftery (2007). Introduces what is now known as the CRPS in the context of subjective probability assessment, establishing the long arc of CRPS-based forecast evaluation that operational hubs continue today. A useful historical anchor for any argument that proper scoring rules have been the dominant evaluation paradigm for ~50 years.

Gneiting, T., & Raftery, A. E. (2007). Strictly proper scoring rules, prediction, and estimation. *Journal of the American Statistical Association*, *102*(477), 359-378. https://doi.org/10.1198/016214506000001437

- The canonical reference defining proper and strictly proper scoring rules for probabilistic forecasts. Establishes the CRPS, logarithmic score, and energy score as proper rules and shows how propriety incentivizes honest reporting of one's predictive distribution. This is the theoretical foundation against which any new trajectory-level score must justify its propriety.

Gneiting, T., Balabdaoui, F., & Raftery, A. E. (2007). Probabilistic forecasts, calibration and sharpness. *Journal of the Royal Statistical Society Series B: Statistical Methodology*, *69*(2), 243-268. https://doi.org/10.1111/j.1467-9868.2007.00587.x

- Formalizes the "sharpness subject to calibration" paradigm: among calibrated forecasters, the one issuing the narrowest predictive distributions is preferred. Directly relevant to the hedger problem, since wide flat forecasts can be marginally calibrated but are not sharp, and current marginal-WIS evaluation does not adequately reward sharpness at the trajectory level.

Bracher, J., Ray, E. L., Gneiting, T., & Reich, N. G. (2021). Evaluating epidemic forecasts in an interval format. *PLOS Computational Biology*, *17*(2), e1008618. https://doi.org/10.1371/journal.pcbi.1008618

- Introduces and motivates the Weighted Interval Score (WIS) as a quantile-based, CRPS-approximating proper scoring rule suited to forecast-hub quantile submissions. Shows WIS decomposes into dispersion, overprediction, and underprediction components. This is the score used by FluSight, the US COVID-19 Forecast Hub, and RESPICAST, and is the direct target of the criticism that motivates the present review.

Hersbach, H. (2000). Decomposition of the continuous ranked probability score for ensemble prediction systems. *Weather and Forecasting*, *15*(5), 559-570. https://doi.org/10.1175/1520-0434(2000)015<0559:DOTCRP>2.0.CO;2

- Provides the operational decomposition of the CRPS into reliability, resolution, and uncertainty components for ensemble forecasts. Useful background for understanding what marginal CRPS rewards and why averaging marginal CRPS across horizons fails to penalize incoherent trajectories that happen to be marginally well-calibrated.

Dawid, A. P., & Sebastiani, P. (1999). Coherent dispersion criteria for optimal experimental design. *The Annals of Statistics*, *27*(1), 65-81. https://doi.org/10.1214/aos/1018031101

- Introduces the Dawid-Sebastiani score (DSS), a proper scoring rule based only on the predictive mean and variance. Computationally trivial relative to CRPS/energy score and naturally extends to multivariate forecasts via the predictive covariance matrix, making it a candidate trajectory-level score when only first two moments are reliable.

Gneiting, T., & Ranjan, R. (2011). Comparing density forecasts using threshold- and quantile-weighted scoring rules. *Journal of Business & Economic Statistics*, *29*(3), 411-422. https://doi.org/10.1198/jbes.2010.08110

- Introduces threshold-weighted and quantile-weighted variants of proper scoring rules that emphasize specified regions of the predictive distribution (e.g., the upper tail). Provides the technical machinery for making CRPS sensitive to particular tail events such as "did the forecast capture the peak?", and is the standard reference cited by subsequent work on decision-relevant probabilistic scoring.

## 2. Multivariate / joint proper scoring rules

Scheuerer, M., & Hamill, T. M. (2015). Variogram-based proper scoring rules for probabilistic forecasts of multivariate quantities. *Monthly Weather Review*, *143*(4), 1321-1334. https://doi.org/10.1175/MWR-D-14-00269.1

- Introduces the variogram score for multivariate probabilistic forecasts, evaluating pairwise differences between forecast components against the corresponding observed differences. Specifically designed to detect mis-specified dependence structure that the energy score is known to miss. Directly applicable to seasonal trajectories: a "flat" forecast will have near-zero forecast variograms while observed trajectories have large peak-to-trough variograms, exposing the hedger.

Gneiting, T., Stanberry, L. I., Grimit, E. P., Held, L., & Johnson, N. A. (2008). Assessing probabilistic forecasts of multivariate quantities, with an application to ensemble predictions of surface winds. *TEST*, *17*(2), 211-235. https://doi.org/10.1007/s11749-008-0114-x

- Establishes the energy score as the principal multivariate generalization of the CRPS and benchmarks it on ensemble weather forecasts. Highlights, however, that the energy score has limited power to detect mis-specified correlation/dependence, a finding that motivated subsequent development of the variogram score and is central to choosing a trajectory-level score.

Pinson, P., & Tastu, J. (2013). *Discrimination ability of the energy score* (DTU Informatics Technical Report No. 2013-15). Technical University of Denmark. https://orbit.dtu.dk/en/publications/discrimination-ability-of-the-energy-score `[citation not verified]`

- Frequently-cited technical report demonstrating empirically and analytically that the energy score has weak discrimination against errors in the dependence structure of a multivariate forecast, while remaining responsive to errors in the marginals. Often cited jointly with Scheuerer & Hamill (2015) as the rationale for preferring the variogram score in trajectory settings. DOI not assigned (technical report).

Allen, S., Bhend, J., Martius, O., & Ziegel, J. F. (2023). Weighted verification tools to evaluate univariate and multivariate probabilistic forecasts for high-impact weather events. *Weather and Forecasting*, *38*(3), 499-516. https://doi.org/10.1175/WAF-D-22-0161.1

- Develops threshold- and region-weighted verification tools for both univariate and multivariate probabilistic forecasts, specifically targeted at high-impact weather events. Provides weighted CRPS, weighted energy score, and weighted variogram score formulations that focus evaluation on regimes operational forecasters care about - directly applicable to epidemic-forecast evaluation conditional on peak regions or threshold exceedances.

Ben Bouallegue, Z., Pinson, P., & Friederichs, P. (2015). Quantile forecast discrimination ability and value. *Quarterly Journal of the Royal Meteorological Society*, *141*(693), 3415-3424. https://doi.org/10.1002/qj.2624

- Connects the discrimination ability of quantile forecasts to economic decision value via a generalized ROC framework. Useful for thinking about decision-relevant evaluation of the same quantile-format forecasts that hubs submit, and motivates evaluation criteria beyond average score (e.g., resolution, discrimination, and operational value).

## 3. Trajectory-level scoring of forecast hubs

Cramer, E. Y., Ray, E. L., Lopez, V. K., Bracher, J., Brennen, A., Castro Rivadeneira, A. J., Gerding, A., Gneiting, T., House, K. H., et al. (2022). Evaluation of individual and ensemble probabilistic forecasts of COVID-19 mortality in the United States. *Proceedings of the National Academy of Sciences*, *119*(15), e2113561119. https://doi.org/10.1073/pnas.2113561119

- The definitive evaluation of the US COVID-19 Forecast Hub. Scores quantile forecasts marginally at each horizon and target with WIS and coverage. Shows that ensembles outperformed individual models on average but documents heterogeneity, especially around peaks, the case where trajectory-level scoring is most needed. This paper is the empirical exemplar of what current marginal-WIS evaluation does and does not detect.

Sherratt, K., Gruson, H., Grah, R., Johnson, H., Niehus, R., Prasse, B., Sandmann, F., Deuschel, J., Wolffram, D., Abbott, S., Ullrich, A., Gibson, G. C., Ray, E. L., Reich, N. G., et al. (2023). Predictive performance of multi-model ensemble forecasts of COVID-19 across European nations. *eLife*, *12*, e81916. https://doi.org/10.7554/eLife.81916

- European counterpart to the US Forecast Hub evaluation. Evaluates 28 modeling teams across 32 countries using marginal WIS. Discusses the limitations of marginal scoring when comparing models with very different sharpness profiles around peaks, troughs, and turning points, directly motivating the search for trajectory-shape-aware metrics.

Bracher, J., Wolffram, D., Deuschel, J., Goergen, K., Ketterer, J. L., Ullrich, A., et al. (2021). A pre-registered short-term forecasting study of COVID-19 in Germany and Poland during the second wave. *Nature Communications*, *12*, 5173. https://doi.org/10.1038/s41467-021-25207-0

- Pre-registered evaluation of the German/Polish COVID-19 Forecast Hub. Notable for its discussion of how horizon-wise marginal scoring obscures the fact that some models produce coherent trajectory samples while others stitch together independently-fitted horizons. A natural setting in which sampled-trajectory (multivariate) scores could distinguish these classes.

Bracher, J., & Held, L. (2022). Endemic-epidemic models with discrete-time serial interval distributions for infectious disease prediction. *International Journal of Forecasting*, *38*(3), 1221-1233. https://doi.org/10.1016/j.ijforecast.2020.07.002

- Develops and evaluates endemic-epidemic models that produce internally coherent multi-step trajectory forecasts. Discusses evaluation of multi-step-ahead distributions and provides an example of how trajectory coherence and uncertainty propagation interact, relevant for designing trajectory-level scoring experiments.

## 4. Functional / shape-based / phase-amplitude evaluation

Berndt, D. J., & Clifford, J. (1994). Using dynamic time warping to find patterns in time series. In *Proceedings of the AAAI-94 Workshop on Knowledge Discovery in Databases* (pp. 359-370). AAAI Press. https://cdn.aaai.org/Workshops/1994/WS-94-03/WS94-03-031.pdf `[citation not verified]`

- The foundational paper introducing dynamic time warping (DTW) for time-series similarity. DTW computes the optimal alignment of two series under monotone time deformations, decoupling shape from phase. Highly cited and the basis for shape-aware comparison metrics that could be adapted to compare predicted vs. observed epidemic curves while tolerating modest phase shifts. AAAI workshop paper without DOI.

Salvador, S., & Chan, P. (2007). Toward accurate dynamic time warping in linear time and space. *Intelligent Data Analysis*, *11*(5), 561-580. https://doi.org/10.3233/IDA-2007-11508

- FastDTW algorithm enabling DTW comparison at scale, including for the many-trajectory ensembles produced by forecast hubs. Practical reference for any implementation that uses DTW-like distance to score sampled trajectories against observed wave shapes.

Alt, H., & Godau, M. (1995). Computing the Frechet distance between two polygonal curves. *International Journal of Computational Geometry & Applications*, *5*(1-2), 75-91. https://doi.org/10.1142/S0218195995000064

- Classical reference for the discrete and continuous Frechet distance, an alternative shape metric to DTW with strong geometric interpretation as the "dog-on-a-leash" distance. Relevant as an additional candidate trajectory-shape metric when one wants to penalize order-preserving but phase-shifted curve matches.

Ramsay, J. O., & Li, X. (1998). Curve registration. *Journal of the Royal Statistical Society Series B: Statistical Methodology*, *60*(2), 351-363. https://doi.org/10.1111/1467-9868.00129

- Introduces curve registration (warping) for separating amplitude and phase variation in functional data. The conceptual framework here, that a "wrong" curve can be wrong in phase, in amplitude, or in shape, is exactly the decomposition we want from a trajectory-level epidemic forecast score, and shows how each component might be scored separately.

Marron, J. S., Ramsay, J. O., Sangalli, L. M., & Srivastava, A. (2015). Functional data analysis of amplitude and phase variation. *Statistical Science*, *30*(4), 468-484. https://doi.org/10.1214/15-STS524

- Definitive overview of amplitude-phase functional data analysis, including the square-root-velocity-function (SRVF) framework due to Srivastava. Provides the modern mathematical apparatus for shape-based comparison of curves, and is directly applicable to scoring sampled forecast trajectories against an observed seasonal trajectory.

## 5. Epidemiologically meaningful / decision-relevant targets

Reich, N. G., Brooks, L. C., Fox, S. J., Kandula, S., McGowan, C. J., Moore, E., Osthus, D., Ray, E. L., et al. (2019). A collaborative multiyear, multimodel assessment of seasonal influenza forecasting in the United States. *Proceedings of the National Academy of Sciences*, *116*(8), 3146-3154. https://doi.org/10.1073/pnas.1812594116

- Landmark FluSight retrospective evaluating multiple seasons and models on the four canonical CDC targets: peak week, peak intensity, season onset, and short-horizon ILI levels. Demonstrates that peak-week and peak-intensity targets reveal model differences that are obscured by averaging short-horizon scores, providing the historical precedent for decision-relevant, trajectory-aware targets.

Reich, N. G., McGowan, C. J., Yamana, T. K., Tushar, A., Ray, E. L., et al. (2019). Accuracy of real-time multi-model ensemble forecasts for seasonal influenza in the U.S. *PLOS Computational Biology*, *15*(11), e1007486. https://doi.org/10.1371/journal.pcbi.1007486

- Companion real-time evaluation of the FluSight Network ensemble. Reports performance separately on short-term incidence vs. peak/onset targets; ensembles dominate on short-term incidence but not always on peak-week and peak-intensity, again motivating evaluation criteria that explicitly target trajectory features.

Brooks, L. C., Farrow, D. C., Hyun, S., Tibshirani, R. J., & Rosenfeld, R. (2018). Nonmechanistic forecasts of seasonal influenza with iterative one-week-ahead distributions. *PLOS Computational Biology*, *14*(6), e1006134. https://doi.org/10.1371/journal.pcbi.1006134

- Describes the Delphi empirical Bayes / EW models used in FluSight. Critically, the paper articulates how iterative one-week-ahead forecasts compose into a full-season trajectory distribution, providing the methodological link from marginal-horizon training to trajectory-level deployment and evaluation.

Biggerstaff, M., Johansson, M., Alper, D., Brooks, L. C., Chakraborty, P., Farrow, D. C., et al. (2018). Results from the second year of a collaborative effort to forecast influenza seasons in the United States. *Epidemics*, *24*, 26-33. https://doi.org/10.1016/j.epidem.2018.02.003

- CDC FluSight 2015-2016 review documenting the operational targets (onset week, peak week, peak intensity, and 1-4 week ahead ILI). Important for understanding which trajectory features the public-health customer historically considered decision-relevant, which any new shape-based score should respect.

McGowan, C. J., Biggerstaff, M., Johansson, M., Apfeldorf, K. M., Ben-Nun, M., Brooks, L., et al. (2019). Collaborative efforts to forecast seasonal influenza in the United States, 2015-2016. *Scientific Reports*, *9*, 683. https://doi.org/10.1038/s41598-018-36361-9

- Parallel write-up to Biggerstaff et al. (2018) with deeper model-by-model results on the canonical FluSight peak and onset targets. A useful reference for the historical record of how peak-timing forecast skill has been operationalized and compared across models.

Funk, S., Camacho, A., Kucharski, A. J., Lowe, R., Eggo, R. M., & Edmunds, W. J. (2019). Assessing the performance of real-time epidemic forecasts: A case study of Ebola in the Western Area region of Sierra Leone, 2014-15. *PLOS Computational Biology*, *15*(2), e1006785. https://doi.org/10.1371/journal.pcbi.1006785

- Influential case study scoring real-time Ebola forecasts using calibration, sharpness, and bias decompositions. The framework, separately reporting calibration and sharpness across the wave, is exactly the diagnostic decomposition that a trajectory-aware score should ideally provide for FluSight/RESPICAST.

Held, L., Meyer, S., & Bracher, J. (2017). Probabilistic forecasting in infectious disease epidemiology: the 13th Armitage lecture. *Statistics in Medicine*, *36*(22), 3443-3460. https://doi.org/10.1002/sim.7363

- Tutorial review of probabilistic forecasting for infectious disease surveillance, including PIT histograms, log-score, and CRPS. Explicitly discusses how decision-relevant evaluation should respect the multi-step, autocorrelated nature of epidemic trajectories, prefiguring the trajectory-scoring research program.

McAndrew, T., & Reich, N. G. (2022). An expert judgment model to predict early stages of the COVID-19 pandemic in the United States. *PLOS Computational Biology*, *18*(9), e1010485. https://doi.org/10.1371/journal.pcbi.1010485

- Demonstrates that human-expert probabilistic judgments can be aggregated into well-calibrated forecasts of pandemic trajectories, including peak features. Provides a non-mechanistic benchmark and emphasizes that decision-makers think in terms of full-season trajectory features (peak, duration, total burden) rather than week-by-week marginals.

## 6. Critiques / alternatives

Entries are ordered chronologically to trace the long arc of how hedging, misspecification, and gameable scoring rules have been critiqued.

Murphy, A. H., & Epstein, E. S. (1967). A note on probability forecasts and "hedging". *Journal of Applied Meteorology*, *6*(6), 1002-1004. https://doi.org/10.1175/1520-0450(1967)006<1002:ANOPFA>2.0.CO;2

- Classical reference identifying that probability forecasters can "hedge" under certain scoring schemes, and analyzing which scoring rules are robust to such hedging. The historical foundation of the hedging-incentive literature; predates the modern proper-scoring-rule framework but raises exactly the concern that motivates the present search for trajectory-aware metrics.

Lerch, S., Thorarinsdottir, T. L., Ravazzolo, F., & Gneiting, T. (2017). Forecaster's dilemma: Extreme events and forecast evaluation. *Statistical Science*, *32*(1), 106-127. https://doi.org/10.1214/16-STS588

- Shows that conditioning forecast evaluation on extreme realized outcomes creates improper incentives, even when using proper scoring rules at the population level. Directly relevant to evaluation around epidemic peaks (the "extreme events" of an epi season) and explains why naive peak-week-only WIS scoring can be gamed.

Patton, A. J. (2020). Comparing possibly misspecified forecasts. *Journal of Business & Economic Statistics*, *38*(4), 796-809. https://doi.org/10.1080/07350015.2019.1585256

- Develops a framework for comparing forecasts that are known to be misspecified - explicitly addressing the realistic case where the modeler cannot remove all bias. Provides asymptotic theory for testing whether one possibly-misspecified forecast dominates another. Directly relevant to the C vs C' question: how do scoring rules compare two forecasters when neither matches the true distribution but they differ in bias-vs-width tradeoffs?

Bosse, N. I., Abbott, S., Cori, A., van Leeuwen, E., Bracher, J., & Funk, S. (2023). Scoring epidemiological forecasts on transformed scales. *PLOS Computational Biology*, *19*(8), e1011393. https://doi.org/10.1371/journal.pcbi.1011393

- Critical examination of how WIS and CRPS behave for epidemic forecasts spanning orders of magnitude. Shows that scoring on the natural (count) scale gives disproportionate weight to peak observations, and proposes log-transformed scoring as a more decision-relevant alternative. A direct, recent critique of current hub practice and a candidate alternative metric.

Gneiting, T., Wolffram, D., Resin, J., Kraus, K., Bracher, J., Dimitriadis, T., Hagenmeyer, V., Jordan, A. I., Lerch, S., Phipps, K., & Schienle, M. (2023). Model diagnostics and forecast evaluation for quantiles. *Annual Review of Statistics and Its Application*, *10*, 597-621. https://doi.org/10.1146/annurev-statistics-032921-020240

- Comprehensive review of quantile-forecast diagnostics, including reliability diagrams, calibration tests, and proper scoring for quantile-format forecasts. Argues that score-only evaluation is insufficient and that diagnostic visualization is needed to detect failure modes such as systematic over-dispersion, a methodological complement to any trajectory-shape score.

Taillardat, M., Fougeres, A.-L., Naveau, P., & de Fondeville, R. (2023). Evaluating probabilistic forecasts of extremes using continuous ranked probability score distributions. *International Journal of Forecasting*, *39*(3), 1448-1459. https://doi.org/10.1016/j.ijforecast.2022.07.003

- Proposes evaluating probabilistic forecasts of extreme events by analyzing the *distribution* of per-observation CRPS values rather than only their mean. The distribution-based approach identifies models whose mean CRPS hides poor tail behavior, which is exactly the failure mode of greatest operational concern around epidemic peaks.

Resin, J., Wolffram, D., Bracher, J., & Dimitriadis, T. (2024). *Shift-dispersion decompositions of Wasserstein and Cramer distances* (arXiv:2408.09770). arXiv. https://doi.org/10.48550/arXiv.2408.09770

- Decomposes the Wasserstein and Cramer distances (the latter being the CRPS) into orthogonal shift and dispersion components. This formally separates "bias" (shift) and "width" (dispersion) contributions to CRPS, making rigorous the bias-vs-width tradeoff that this notebook's C vs C' comparison illustrates empirically. Co-authored by Bracher, Wolffram, and Dimitriadis, who together represent much of the European forecast-hub evaluation community, and methodologically continuous with this bibliography's Sections 1 and 3.

Buchweitz, E., Romano, J. V., & Tibshirani, R. J. (2025). *Asymmetric penalties underlie proper loss functions in probabilistic forecasting* (arXiv:2505.00937). arXiv. https://doi.org/10.48550/arXiv.2505.00937

- Proves that a broad class of proper scoring rules - log loss, CRPS, quadratic, spherical, energy, and threshold-weighted CRPS - penalize under- vs. over-estimation of a distributional parameter asymmetrically. The applied consequence is that hedging becomes optimal under distribution shift: a forecaster who knows their model is mis-specified relative to current conditions can systematically improve their expected score by biasing predictions in the under-penalized direction, without moving closer to truth. This is the theoretical underpinning of the "width-laundering of bias" failure mode and a strong recent argument that proper-scoring-rule guarantees do not, on their own, protect operational hubs against gameable forecaster behavior.
