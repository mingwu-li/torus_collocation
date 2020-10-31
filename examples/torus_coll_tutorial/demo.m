%% Continuation of quasiperiodic invariant tori
%
% Two-dimensional quasiperiodic invariant tori are characterized by a
% parallel flow with irrational rotation number. In terms of a suitably
% defined torus function, the dynamics on the torus may be described by an
% invariant circle that is mapped to itself by the flow, such that the flow
% is equivalent to a rigid rotation on the circle.
%
% We obtain an approximate description of a quasiperiodic invariant torus
% in terms of a Fourier representation of the invariant circle and a finite
% collection of trajectory segments based at points on the invariant
% circle. The rigid rotation imposes an all-to-all coupled system of
% boundary conditions on the collection of trajectory segments.

% Panel (a) shows a quasiperiodic arc, representing a family of
% quasiperiodic invariant tori. The slope of the arc is the rotation number
% which is held constant during continuation. Selected members of this
% family are shown in panels (b) to (f).

%% Encoding
% construct the guess of initial solution
om   = 1.5;
Om   = 1;
N    = 15;  % 2N+1 = Number of orbit segments
vphi = 2*pi*linspace(0,1,2*N+2);
tau  = 2*pi/om*linspace(0,1,10*(2*N+1))';
rho  = (1+om^2)./(1+om^2-cos(om*tau)-om*sin(om*tau));
up   = zeros(numel(tau),2,2*N+1);
for i=1:2*N+1
  up(:,:,i) = repmat(rho, [1 2]).*[cos(Om*tau+vphi(i)) sin(Om*tau+vphi(i))];
end

varrho = 1/1.51111;

% construct continuation problem
prob = coco_prob();
prob = coco_set(prob, 'coll', 'NTST', 20);
prob = coco_set(prob, 'cont', 'NAdapt', 2, 'h_max', 10);
torargs = {@torus @torus_DFDX @torus_DFDP @torus_DFDT tau up {'Om2','Om','om1','om2','varrho'} [om Om Om om varrho]};
prob = ode_isol2tor(prob, '', torargs{:});

fprintf('\n Run=''%s'': Continue family of quasiperiodic invariant tori.\n', ...
  'torus');

coco(prob, 'torus', [], 1, {'Om2' 'om2' 'om1' 'Om' 'varrho'}, [0.5 1.5]);

%% Graphical representation of stored solutions

% Figure 1
figure(1); clf
coco_plot_bd('torus', 'om1', 'om2')
grid on


%% New run with varied varrho
lab  = 1;
prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 2, 'h_max', 10);
prob = ode_tor2tor(prob, '', 'torus', lab);
coco(prob, 'torus_varrho', [], 1, {'Om2' 'om2' 'varrho' 'Om' 'om1'}, [0.5 1.5]);

% Figure 2
figure(2); clf
coco_plot_bd('torus_varrho', 'varrho', 'om2')
grid on

bd = coco_bd_read('torus_varrho');
labs = coco_bd_labs(bd);

for i=1:numel(labs)
  figure(i+1); clf; hold on; grid on
  
  [sol, data] = bvp_read_solution('tor', 'torus_varrho', labs(i));
  N  = data.nsegs;
  M  = size(sol{1}.xbp,1);
  x0 = zeros(N+1,2);
  x1 = zeros(N+1,2);
  XX = zeros(M,N+1);
  YY = XX;
  ZZ = XX;
  for j=1:N+1
    n       = mod(j-1,N)+1;
    XX(:,j) = sol{n}.xbp(1:M,1);
    ZZ(:,j) = sol{n}.xbp(1:M,2);
    YY(:,j) = sol{n}.tbp(1:M);
    x0(j,:) = sol{n}.xbp(1,:);
    x1(j,:) = sol{n}.xbp(M,:);
  end
  surf(XX, YY, ZZ, 'FaceColor', 0.9*[1 1 1], 'FaceAlpha', 0.7, ...
    'MeshStyle', 'column', 'LineStyle', '-', 'EdgeColor', 0.6*[1 1 1], ...
    'LineWidth', 0.5);
  plot3(x0(:,1), zeros(N+1,1), x0(:,2), 'LineStyle', '-', 'LineWidth', 2, ...
    'Color', 'black', 'Marker', '.', 'MarkerSize', 12);
  plot3(x1(:,1), sol{n}.T*ones(N+1,1), x1(:,2), 'LineStyle', '-', 'LineWidth', 2, ...
    'Color', 'blue', 'Marker', '.', 'MarkerSize', 12);
  
  hold off; view([50 15])
end
