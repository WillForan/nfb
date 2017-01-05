function [texture, bbox] = MakeTextTexture(window, text, bgColor, textFont, textSize, textColor)

    if exist('textFont', 'var') && ~isempty(textFont)
        oldFont = Screen('TextFont', window, textFont);
    end

    if exist('textSize', 'var') && ~isempty(textSize)
        oldTextSize = Screen('TextSize', window, textSize);
    end

    if exist('textColor', 'var') && ~isempty(textColor)
        oldTextColor = Screen('TextColor', window, textColor);
    end

    box = Screen('TextBounds', window, text);
    nx = ceil((box(3) - box(1))*1.1);
    if mod(nx, 2)
        nx = nx + 1;
    end

    ny = ceil((box(4) - box(2))*1.1);
    if mod(ny, 2)
        ny = ny + 1;
    end

    textureRect = ones(ny, nx);
    bbox = [0 0 nx ny];
    texture = Screen('MakeTexture', window, textureRect);
    Screen('FillRect', texture, bgColor);

    if exist('textFont', 'var') && ~isempty(textFont)
        Screen('TextFont', texture, textFont);
    end

    if exist('textSize', 'var') && ~isempty(textSize)
        Screen('TextSize', texture, textSize);
    end

    if exist('textColor', 'var') && ~isempty(textColor)
        Screen('TextColor', texture, textColor);
    end
    
    DrawFormattedText(texture, text, 'center', 'center');
   
    % reset window options 
    if exist('textFont', 'var') && ~isempty(textFont)
        Screen('TextFont', window, oldFont);
    end

    if exist('textSize', 'var') && ~isempty(textSize)
        Screen('TextSize', window, oldTextSize);
    end

    if exist('textColor', 'var') && ~isempty(textColor)
        Screen('TextColor', window, oldTextColor);
    end
end
