/* Самостоятельная работа основана на базе данных, которая хранит информацию о венчурных фондах и инвестициях в компании-стартапы, 
и основана на датасете Startup Investments (https://www.kaggle.com/justinas/startup-investments) */

/* Задание 1 */
Посчитайте, сколько компаний закрылось

SELECT COUNT(*)
FROM company
WHERE status = 'closed';

/* Задание 2 */
Отобразите количество привлечённых средств для новостных компаний США.
Используйте данные из таблицы company. Отсортируйте таблицу по убыванию значений в поле `funding_total`

SELECT funding_total
FROM company
WHERE category_code = 'news'
  AND country_code = 'USA'
ORDER BY funding_total DESC;

/* Задание 3 */
Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно

SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash'
  AND EXTRACT(YEAR FROM acquired_at) BETWEEN 2011 AND 2013;

/* Задание 4 */
Отобразите имя, фамилию и названия аккаунтов людей в твиттере, у которых названия аккаунтов начинаются на `'Silver'`

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

/* Задание 5 */
Выведите на экран всю информацию о людях, у которых названия аккаунтов в твиттере содержат подстроку `'money'`, а фамилия начинается на `'K'`

SELECT *
FROM people
WHERE twitter_username LIKE '%money%'
  AND last_name LIKE 'K%';

/* Задание 6 */
Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы

SELECT country_code,
       SUM(funding_total) AS total_invest
FROM company 
GROUP BY country_code
ORDER BY total_invest DESC;

/* Задание 7 */
Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату. Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.

SELECT funded_at,
       MIN(raised_amount) AS min_amount,
       MAX(raised_amount) AS max_amount
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) NOT IN (0, MAX(raised_amount));

/* Задание 8 */
Создайте поле с категориями:

Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию `high_activity`.

Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию `middle_activity`.

Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию `low_activity`.

Отобразите все поля таблицы `fund` и новое поле с категориями

SELECT *, 
       CASE
           WHEN invested_companies >= 100 THEN 'high_activity'
           WHEN invested_companies < 20 THEN 'low_activity'
           ELSE 'middle_activity'
       END
FROM fund;

/* Задание 9 */
Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. 

Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.

SELECT *,
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity
FROM fund;

/* Задание 10 */
Выгрузите таблицу с десятью самыми активными инвестирующими странами. Активность страны определите по среднему количеству компаний, в которые инвестируют фонды этой страны.

Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды, основанные с 2010 по 2012 год включительно.

Исключите из таблицы страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. Отсортируйте таблицу по среднему количеству компаний от большего к меньшему.

Для фильтрации диапазона по годам используйте оператор BETWEEN

SELECT country_code,
       MIN(invested_companies) AS min_count,
       MAX(invested_companies) AS max_count,
       AVG(invested_companies) AS avg_count
FROM fund
WHERE EXTRACT(YEAR FROM founded_at) BETWEEN 2010 AND 2012
GROUP BY country_code
HAVING MIN(invested_companies) > 0
ORDER BY avg_count DESC, country_code
LIMIT 10;

/* Задание 11 */
Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна

SELECT first_name,
       last_name,
       e.instituition
FROM people AS p
LEFT JOIN education AS e ON p.id = e.person_id;

/* Задание 12 */
Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. 

Выведите название компании и число уникальных названий учебных заведений. 

Составьте топ-5 компаний по количеству университетов

SELECT c.name,
       COUNT(DISTINCT instituition) AS cnt_grad
FROM company AS c
JOIN people AS p ON c.id = p.company_id
JOIN education AS e ON p.id = e.person_id
GROUP BY c.name
ORDER BY cnt_grad DESC
LIMIT 5;

/* Задание 13 */
Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним

SELECT DISTINCT name
FROM company AS c
JOIN funding_round AS fr ON c.id = fr.company_id
WHERE status = 'closed'
  AND is_first_round = 1
  AND is_last_round = 1;

/* Задание 14 */
Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании

SELECT DISTINCT people.id
FROM people
WHERE company_id IN (SELECT company_id
                     FROM company AS c
                     JOIN funding_round AS fr ON c.id = fr.company_id
                     WHERE status = 'closed'
                       AND is_first_round = 1
                       AND is_last_round = 1
                    );

/* Задание 15 */
Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник

SELECT DISTINCT p.id,
       e.instituition
FROM people AS p
JOIN education AS e ON p.id = e.person_id
WHERE company_id IN (SELECT company_id
                     FROM company AS c
                     JOIN funding_round AS fr ON c.id = fr.company_id
                     WHERE status = 'closed'
                       AND is_first_round = 1
                       AND is_last_round = 1
                    );

/* Задание 16 */
Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания

SELECT DISTINCT p.id,
       COUNT(e.instituition)
FROM people AS p
JOIN education AS e ON p.id = e.person_id
WHERE company_id IN (SELECT company_id
                     FROM company AS c
                     JOIN funding_round AS fr ON c.id = fr.company_id
                     WHERE status = 'closed'
                       AND is_first_round = 1
                       AND is_last_round = 1
                    )
GROUP BY p.id;

/* Задание 17 */
Дополните предыдущий запрос и выведите среднее число учебных заведений, которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится

WITH
i AS (SELECT DISTINCT p.id,
             COUNT(e.instituition) AS cnt_ed
      FROM people AS p
      JOIN education AS e ON p.id = e.person_id
      WHERE company_id IN (SELECT company_id
                           FROM company AS c
                           JOIN funding_round AS fr ON c.id = fr.company_id
                           WHERE status = 'closed'
                             AND is_first_round = 1
                             AND is_last_round = 1
                    )
      GROUP BY p.id
     )

SELECT AVG(cnt_ed)
FROM i;

/* Задание 18 */
Напишите похожий запрос: выведите среднее число учебных заведений, которые окончили сотрудники компании Facebook

SELECT AVG(i.cnt_inst)
FROM (
    SELECT DISTINCT p.id,
           COUNT(instituition) AS cnt_inst
    FROM company AS c
    JOIN people AS p ON c.id = p.company_id
    LEFT JOIN education AS e ON p.id = e.person_id
    WHERE name = 'Facebook'
      AND e.instituition IS NOT NULL
    GROUP BY p.id
) AS i;

/* Задание 19 */
Составьте таблицу из полей:

- `name_of_fund` — название фонда;
- `name_of_company` — название компании;
- `amount` — сумма инвестиций, которую привлекла компания в раунде.

В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно

SELECT f.name AS name_of_fund,
       c.name AS name_of_company,
       fr.raised_amount AS amount
FROM investment  AS inv
JOIN company AS c ON inv.company_id = c.id
JOIN fund AS f ON inv.fund_id = f.id
JOIN funding_round AS fr ON inv.funding_round_id = fr.id
WHERE c.milestones > 6
  AND EXTRACT(YEAR FROM funded_at) BETWEEN 2012 AND 2013;

/* Задание 20 */
Выгрузите таблицу, в которой будут такие поля:

- название компании-покупателя;
- сумма сделки;
- название компании, которую купили;
- сумма инвестиций, вложенных в купленную компанию;
- доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.

Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы.

Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в алфавитном порядке. Ограничьте таблицу первыми десятью записями

WITH 
acquiring AS (SELECT c.name AS buyer, -- название компании-покупателя
              a.price_amount AS price, -- сумма сделки
              a.id AS KEY
              FROM acquisition AS a
              LEFT JOIN company AS c ON a.acquiring_company_id = c.id
              WHERE a.price_amount > 0
             ),

acquired AS (SELECT c.name AS acquisition, -- название компании, которую купили
             c.funding_total AS investment, -- сумма инвестиций, вложенных в купленную компанию
             a.id AS KEY
             FROM acquisition AS a
             LEFT JOIN company AS c ON a.acquired_company_id = c.id
             WHERE c.funding_total > 0
            )

SELECT buyer,
       price,
       acquisition,
       investment,
       ROUND(price / investment) AS fraction -- доля
FROM acquiring AS acqn
JOIN acquired AS acqd ON acqn.KEY = acqd.KEY
ORDER BY price DESC, acquisition
LIMIT 10;

/* Задание 21 */

Выгрузите таблицу, в которую войдут названия компаний из категории `social`, получившие финансирование с 2010 по 2013 год.

Выведите также номер месяца, в котором проходил раунд финансирования

SELECT c.name,
       EXTRACT(MONTH FROM fr.funded_at) AS month
FROM company AS c
LEFT JOIN funding_round AS fr ON c.id = fr.company_id
WHERE c.category_code = 'social'
  AND EXTRACT(YEAR FROM fr.funded_at) BETWEEN 2010 AND 2013
  AND fr.raised_amount > 0;

/* Задание 22 */
Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды.

Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:

- номер месяца, в котором проходили раунды;
- количество уникальных названий фондов из США, которые инвестировали в этом месяце;
- количество компаний, купленных за этот месяц;
- общая сумма сделок по покупкам в этом месяце

WITH fundings AS (SELECT EXTRACT(MONTH FROM CAST(fr.funded_at AS DATE)) AS funding_month,
                         COUNT(DISTINCT f.id) AS us_funds
                  FROM fund AS f
                  LEFT JOIN investment AS i ON f.id = i.fund_id
                  LEFT JOIN funding_round AS fr ON i.funding_round_id = fr.id
                  WHERE f.country_code = 'USA'
                    AND EXTRACT(YEAR FROM CAST(fr.funded_at AS DATE)) BETWEEN 2010 AND 2013
                  GROUP BY funding_month
                 ),
acquisitions AS (SELECT EXTRACT(MONTH FROM CAST(acquired_at AS DATE)) AS funding_month,
                        COUNT(acquired_company_id) AS bought_co,
                        SUM(price_amount) AS sum_total
                 FROM acquisition
                 WHERE EXTRACT(YEAR FROM CAST(acquired_at AS DATE)) BETWEEN 2010 AND 2013
                 GROUP BY funding_month
                )

SELECT fnd.funding_month, 
       fnd.us_funds, 
       acq.bought_co, 
       acq.sum_total
FROM fundings AS fnd
LEFT JOIN acquisitions AS acq ON fnd.funding_month = acq.funding_month;

/* Задание 23 */
Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. 

Данные за каждый год должны быть в отдельном поле. Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему

WITH
a AS (SELECT country_code,
             AVG(funding_total) AS totalavg_2011
      FROM company
      WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = 2011
      GROUP BY country_code
     ),

b AS (SELECT country_code,
             AVG(funding_total) AS totalavg_2012
      FROM company
      WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = 2012
      GROUP BY country_code
     ),
     
c AS (SELECT country_code,
             AVG(funding_total) AS totalavg_2013
      FROM company
      WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = 2013
      GROUP BY country_code
     )
     
SELECT a.country_code,
       a.totalavg_2011,
       b.totalavg_2012,
       c.totalavg_2013
FROM a 
INNER JOIN b ON a.country_code = b.country_code 
INNER JOIN c ON a.country_code = c.country_code
ORDER BY totalavg_2011 DESC;