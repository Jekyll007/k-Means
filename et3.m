function et3
    % ��������� ������ ��� ����� ������
    classNums = inputdlg('���������� ���������:',...
                      '���. �3',...
                      1,...
                      {'3'});
    % ���� ������ ������ - ���������� ��
    if isempty(classNums); return; end
    
    classNums = str2double(classNums);
    % ��������� Excel
    system('taskkill /F /IM EXCEL.EXE');
    try
        % ������ ������ � ��������� ������� �� �����
        % � ������������ ������� ��������
        objs = [xlsread('irfishE.xlsx',1,'B4:E53');...
                xlsread('irfishE.xlsx',1,'F4:I53');...
                xlsread('irfishE.xlsx',1,'J4:M53')];
    catch
        errordlg('�������� Excel � ������������� ���������');
        return;
    end
    
    % �������� ��������� ��������������� ������� ��������,
    % ������� ����� ���������� �������� ���������
    clustCentrInd = randperm(size(objs,1),classNums);
    % �������� ��������� ������ ���������
    clustCents = objs(clustCentrInd,:);
    % �������� �������� (��������� � ������������ �������� ������� ����)
    [classt,step] = myKMeans(objs,classNums,clustCents);
    % ����������� � ������� �������� (������) ������� � ����������� �������
    objs = [objs classt];
    % ���������� ���������� ��������� �������������
    plotResult(objs,classt,classNums)

    
    % �������� ������� �� ��������� ���� ������ (�� 50 ��.) � ������� � Excel
    try
        xlswrite('irfishE.xlsx',objs(1:50,1:end),2,'A3');
        xlswrite('irfishE.xlsx',objs(51:100,1:end),2,'G3');
        xlswrite('irfishE.xlsx',objs(101:150,1:end),2,'M3');
        % ������� ��������� ������ ��������� � �� ������� � ������� ��������
        xlswrite('irfishE.xlsx',[clustCents clustCentrInd'],2,'S5');
        % ������� ���������� ��������
        xlswrite('irfishE.xlsx',step,2,'S2');
        % ������� Excel-����
        winopen('irfishE.xlsx');
    catch
        warning('�������� Excel � ������������� ���������');
    end

    

% �������� �-��������������� �������
% ����:
% objs - ������� �����-�������� � ���������� (���������) 
% classNums - ���������� ���������
% oldClustCents - ������ ��������� �������� ��� �������������� ������� ���������
% ���������� �������� � ������� ������ ���� ����� ���������� ��������� 
% �����:
% �lasst - ������ �������������� �������� � ���������
% ������ �������� ������� ������������� ������� � �������� �������
% step - ���, �� ������� ���������� ��������
function [classt,step] = myKMeans(objs,classNums,oldClustCents)
    % �������������� ������������ ����������, �� �� ���-������������
    % ������ ���������� �� ������� ���������
    dists = zeros(1,classNums);
    % ������ �������������� � ���������
    classt = zeros(size(objs,1),1);
    % ���-�� ��������
    step = 0;
    % ������ � ��������� �������� ��� ������� ������
    clustElems = cell(1,classNums);
    % ������ ��� ����� ������� ���������
    clustCents = zeros(classNums,size(objs,2));
    
    % ���������� 
    while 1
        step = step+1;
        % ����������� �������� ��� ������� ������� �������
        for i = 1:size(objs,1)
            for j = 1:classNums
                % ��������� ���������� �� ������� �� ������ ������� ��������
                dists(j) = pdist([objs(i,:); oldClustCents(j,:)],'euclidean');
                % ��������� �������
                [~,classt(i,1)] = min(dists);
            end
        end

        % ����������� ��������� �� ��������� ��� ������ � ����
        % � ������ i-�� ������ clustElems ����� ������ ������� i-�� ������
        for i = 1:size(objs,1)
            for j = 1:classNums
                 % ������������ ������ ��������� ��� ������� ������
                 clustElems{j} = objs(classt(:)==j,:);
            end
        end

        % ������ ����� ������� ���������
        for i = 1:classNums
            % ������� "������" � ������ ��������
        	clustCents(i,:) = mean(clustElems{i});
        end

        % ������� ������: ���� ������ ��������� �� � � �+1 ���� �����
        if isequal(clustCents,oldClustCents); break; end;

        % ������ ����� ������ �������� �������
        oldClustCents = clustCents;
    end
    
    
 function plotResult(objs,classt,classNums)
    % ������ ����������
    % ������� ������: ������� �������� objs + ������� ������������ �������
    figure('Name','������������ ����������� ������ ��������� � ����������� ������������','Color','white');
    % �������� �������
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
                        text(0.5,0.5,{'�����','�����������'},'HorizontalAlignment','center','Parent',sh);
                    case 2
                        text(0.5,0.5,{'������','�����������'},'HorizontalAlignment','center','Parent',sh);
                    case 3
                        text(0.5,0.5,{'�����','��������'},'HorizontalAlignment','center','Parent',sh);
                    case 4
                        text(0.5,0.5,{'������','��������'},'HorizontalAlignment','center','Parent',sh);
                end
            end
            sptf = sptf+1;
        end
    end
    