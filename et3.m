function et3
    % открываем диалог для ввода данных
    classNums = inputdlg('Количество кластеров:',...
                      'Лаб. №3',...
                      1,...
                      {'3'});
    % если нажали отмену - прекращаем всё
    if isempty(classNums); return; end
    
    classNums = str2double(classNums);
    % закрываем Excel
    system('taskkill /F /IM EXCEL.EXE');
    try
        % чтение матриц с исходными данными из файла
        % и формирование массива объектов
        objs = [xlsread('irfishE.xlsx',1,'B4:E53');...
                xlsread('irfishE.xlsx',1,'F4:I53');...
                xlsread('irfishE.xlsx',1,'J4:M53')];
    catch
        errordlg('Закройте Excel и перезапустите программу');
        return;
    end
    
    % получаем случайные неповторяющиеся индексы объектов,
    % которые будут начальными центрами кластеров
    clustCentrInd = randperm(size(objs,1),classNums);
    % выбираем начальные центры кластеров
    clustCents = objs(clustCentrInd,:);
    % вызываем алгоритм (аргументы и возвращаемые значения описаны ниже)
    [classt,step] = myKMeans(objs,classNums,clustCents);
    % присоединим к выборке объектов (справа) столбец с определённым классом
    objs = [objs classt];
    % графически отображаем результат классификации
    plotResult(objs,classt,classNums)

    
    % разобьём выборку на известные типы ирисов (по 50 шт.) и запишем в Excel
    try
        xlswrite('irfishE.xlsx',objs(1:50,1:end),2,'A3');
        xlswrite('irfishE.xlsx',objs(51:100,1:end),2,'G3');
        xlswrite('irfishE.xlsx',objs(101:150,1:end),2,'M3');
        % запишем начальные центры кластеров и их индексы в выборке объектов
        xlswrite('irfishE.xlsx',[clustCents clustCentrInd'],2,'S5');
        % запишем количество итераций
        xlswrite('irfishE.xlsx',step,2,'S2');
        % откроем Excel-файл
        winopen('irfishE.xlsx');
    catch
        warning('Закройте Excel и перезапустите программу');
    end

    

% АЛГОРИТМ К-ВНУТРИГРУППОВЫХ СРЕДНИХ
% ВХОД:
% objs - матрица строк-объектов с признаками (столбцами) 
% classNums - количество кластеров
% oldClustCents - массив случайных объектов для первоначальных центров кластеров
% количество объектов в массиве должно быть равно количеству кластеров 
% ВЫХОД:
% сlasst - массив принадлежности объектов к кластерам
% индекс элемента массива соответствует объекту в исходном массиве
% step - шаг, на котором завершился алгоритм
function [classt,step] = myKMeans(objs,classNums,oldClustCents)
    % инициализируем используемые переменные, мы же тру-программерыЪ
    % массив расстояний до центров кластеров
    dists = zeros(1,classNums);
    % массив принадлежности к кластерам
    classt = zeros(size(objs,1),1);
    % кол-во итераций
    step = 0;
    % ячейки с матрицами объектов для каждого класса
    clustElems = cell(1,classNums);
    % массив для новых центров кластеров
    clustCents = zeros(classNums,size(objs,2));
    
    % вычисление 
    while 1
        step = step+1;
        % определение кластера для каждого объекта выборки
        for i = 1:size(objs,1)
            for j = 1:classNums
                % евклидово расстояние от объекта до центра каждого кластера
                dists(j) = pdist([objs(i,:); oldClustCents(j,:)],'euclidean');
                % ближайший кластер
                [~,classt(i,1)] = min(dists);
            end
        end

        % объединение элементов по кластерам для работы с ними
        % в каждой i-ой ячейке clustElems будут лежать объекты i-го класса
        for i = 1:size(objs,1)
            for j = 1:classNums
                 % формирование матриц элементов для каждого класса
                 clustElems{j} = objs(classt(:)==j,:);
            end
        end

        % расчёт новых центров кластеров
        for i = 1:classNums
            % находим "эталон" в каждом кластере
        	clustCents(i,:) = mean(clustElems{i});
        end

        % условие выхода: если центры кластеров на к и к+1 шаге равны
        if isequal(clustCents,oldClustCents); break; end;

        % делаем новые центры кластера старыми
        oldClustCents = clustCents;
    end
    
    
 function plotResult(objs,classt,classNums)
    % ГРАФИК РЕЗУЛЬТАТА
    % входные данные: выборка объектов objs + индексы соответствия классам
    figure('Name','Визуализация результатов работы алгоритма в признаковом пространстве','Color','white');
    % выделяем выборки
    for k = 1:classNums
        clustElemsN{k} = objs(classt(:)==k,:);
    end
    colorM = {'.r','.g','.b','.k','.y'};
    msize = 4;
    sptf = 1;
    for i = 1:4
        for j = 1:4
            sh = subplot(4,4,sptf);
            if i~=j
                for k = 1:classNums
                    plot(clustElemsN{k}(:,i),clustElemsN{k}(:,j),colorM{k},'markers',msize);
                    hold on;
                end
            else
                axis off;
                switch i
                    case 1
                        text(0.5,0.5,{'Длина','чашелистика'},'HorizontalAlignment','center','Parent',sh);
                    case 2
                        text(0.5,0.5,{'Ширина','чашелистика'},'HorizontalAlignment','center','Parent',sh);
                    case 3
                        text(0.5,0.5,{'Длина','лепестка'},'HorizontalAlignment','center','Parent',sh);
                    case 4
                        text(0.5,0.5,{'Ширина','лепестка'},'HorizontalAlignment','center','Parent',sh);
                end
            end
            sptf = sptf+1;
        end
    end
    